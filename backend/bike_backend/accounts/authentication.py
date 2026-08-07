"""Reads the Bearer token and attaches request.user — completely
independent of django.contrib.auth's session/backend system."""
import jwt
from rest_framework import authentication, exceptions
from .models import AppUser
from .tokens import decode_token


class CustomJWTAuthentication(authentication.BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return None

        token = auth_header.split(' ', 1)[1]
        try:
            payload = decode_token(token, expected_type='access')
        except jwt.ExpiredSignatureError:
            raise exceptions.AuthenticationFailed('Access token expired.')
        except jwt.InvalidTokenError:
            raise exceptions.AuthenticationFailed('Invalid token.')

        try:
            user = AppUser.objects.get(id=payload['user_id'], is_active=True)
        except AppUser.DoesNotExist:
            raise exceptions.AuthenticationFailed('User not found.')

        return (user, None)