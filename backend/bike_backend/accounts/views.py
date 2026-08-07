import jwt
import datetime
from django.conf import settings
from django.core.mail import send_mail

from rest_framework import status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView

import requests as http_requests

from .models import AppUser
from .tokens import generate_tokens
from .models import AppUser, BlacklistedToken
from .hashers import verify_password
from .tokens import generate_tokens, decode_token, ALGORITHM
from .serializers import (
    GoogleAuthSerializer, 
    RegisterSerializer, 
    LoginSerializer, 
    UserSerializer,
    PasswordResetRequestSerializer, 
    PasswordResetConfirmSerializer,
)


class RegisterView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        access, refresh = generate_tokens(user)
        return Response(
            {'user': UserSerializer(user).data, 'access': access, 'refresh': refresh},
            status=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        username = serializer.validated_data['username']
        password = serializer.validated_data['password']

        user = AppUser.objects.filter(username__iexact=username, is_active=True).first()
        if not user or not verify_password(password, user.password_hash):
            return Response({'detail': 'Invalid username or password.'}, status=status.HTTP_401_UNAUTHORIZED)

        access, refresh = generate_tokens(user)
        return Response({'user': UserSerializer(user).data, 'access': access, 'refresh': refresh})


class RefreshView(APIView):
    """POST /api/accounts/login/refresh/  — body: {refresh}"""
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        token = request.data.get('refresh')
        if not token:
            return Response({'detail': 'refresh is required.'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            payload = decode_token(token, expected_type='refresh')
        except jwt.ExpiredSignatureError:
            return Response({'detail': 'Refresh token expired.'}, status=status.HTTP_401_UNAUTHORIZED)
        except jwt.InvalidTokenError:
            return Response({'detail': 'Invalid refresh token.'}, status=status.HTTP_401_UNAUTHORIZED)

        if BlacklistedToken.objects.filter(jti=payload['jti']).exists():
            return Response({'detail': 'This session has been logged out.'}, status=status.HTTP_401_UNAUTHORIZED)

        user = AppUser.objects.filter(id=payload['user_id'], is_active=True).first()
        if not user:
            return Response({'detail': 'User not found.'}, status=status.HTTP_401_UNAUTHORIZED)

        access, _ = generate_tokens(user)
        return Response({'access': access})


class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        token = request.data.get('refresh')
        if not token:
            return Response({'detail': 'refresh is required.'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            payload = decode_token(token, expected_type='refresh')
            BlacklistedToken.objects.get_or_create(jti=payload['jti'])
        except jwt.InvalidTokenError:
            pass  # already unusable, nothing more to do
        return Response({'detail': 'Logged out successfully.'}, status=status.HTTP_205_RESET_CONTENT)


class PasswordResetRequestView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']

        user = AppUser.objects.filter(email__iexact=email).first()
        if user:
            now = datetime.datetime.utcnow()
            token = jwt.encode(
                {'user_id': user.id, 'type': 'password_reset', 'iat': now, 'exp': now + datetime.timedelta(minutes=20)},
                settings.SECRET_KEY, algorithm=ALGORITHM,
            )
            reset_link = f"{settings.FRONTEND_RESET_URL}?token={token}"
            send_mail(
                subject='Reset your VAYU account password',
                message=f'Tap the link below to set a new password (expires in 20 minutes):\n\n{reset_link}',
                from_email=None,
                recipient_list=[email],
            )
        return Response({'detail': 'If an account with that email exists, a reset link has been sent.'})


class PasswordResetConfirmView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            payload = decode_token(serializer.validated_data['token'], expected_type='password_reset')
        except jwt.ExpiredSignatureError:
            return Response({'detail': 'This reset link has expired.'}, status=status.HTTP_400_BAD_REQUEST)
        except jwt.InvalidTokenError:
            return Response({'detail': 'Invalid reset link.'}, status=status.HTTP_400_BAD_REQUEST)

        from .hashers import hash_password
        user = AppUser.objects.filter(id=payload['user_id']).first()
        if not user:
            return Response({'detail': 'Invalid reset link.'}, status=status.HTTP_400_BAD_REQUEST)

        user.password_hash = hash_password(serializer.validated_data['new_password'])
        user.save()
        return Response({'detail': 'Password has been reset successfully.'})


class ProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user).data)

    def patch(self, request):
        serializer = UserSerializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

class GoogleLoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = GoogleAuthSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        resp = http_requests.get(
            "https://www.googleapis.com/oauth2/v3/userinfo",
            headers={"Authorization": f"Bearer {serializer.validated_data['access_token']}"},
        )
        if resp.status_code != 200:
            return Response(
                {"detail": "Invalid or expired Google token."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        payload = resp.json()
        email = payload.get("email")

        if not email:
            return Response(
                {"detail": "Google account has no email."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = AppUser.objects.filter(email__iexact=email).first()

        if not user:
            base_username = email.split("@")[0]
            username = base_username
            number = 1

            while AppUser.objects.filter(username=username).exists():
                number += 1
                username = f"{base_username}{number}"

            user = AppUser.objects.create(
                username=username,
                email=email,
                first_name=payload.get("given_name", ""),
                last_name=payload.get("family_name", ""),
                password_hash="",  # Google users don't use passwords
                is_active=True,
            )

        access, refresh = generate_tokens(user)

        return Response({
            "user": UserSerializer(user).data,
            "access": access,
            "refresh": refresh,
        })