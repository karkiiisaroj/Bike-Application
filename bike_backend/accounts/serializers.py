from django.contrib.auth.models import User
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from .models import Profile


class RegisterSerializer(serializers.ModelSerializer):

    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = (
            "username",
            "email",
            "password",
            "first_name",
            "last_name",
        )

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)


class ProfileSerializer(serializers.ModelSerializer):

    username = serializers.CharField(
        source="user.username",
        read_only=True
    )

    email = serializers.EmailField(
        source="user.email",
        read_only=True
    )

    first_name = serializers.CharField(
        source="user.first_name",
        read_only=True
    )

    last_name = serializers.CharField(
        source="user.last_name",
        read_only=True
    )

    class Meta:
        model = Profile
        fields = "__all__"

class UpdateProfileSerializer(serializers.ModelSerializer):

    first_name = serializers.CharField(
        source="user.first_name",
        required=False
    )

    last_name = serializers.CharField(
        source="user.last_name",
        required=False
    )

    email = serializers.EmailField(
        source="user.email",
        required=False
    )

    class Meta:
        model = Profile
        fields = (
            "first_name",
            "last_name",
            "email",
            "phone",
            "date_of_birth",
            "address",
            "city",
            "province",
            "country",
            "profile_image",
        )

    def update(self, instance, validated_data):

        user_data = validated_data.pop("user", {})

        user = instance.user

        user.first_name = user_data.get(
            "first_name",
            user.first_name
        )

        user.last_name = user_data.get(
            "last_name",
            user.last_name
        )

        user.email = user_data.get(
            "email",
            user.email
        )

        user.save()

        return super().update(instance, validated_data)

from django.contrib.auth.password_validation import validate_password


class ChangePasswordSerializer(serializers.Serializer):

    old_password = serializers.CharField()

    new_password = serializers.CharField()

    def validate_new_password(self, value):

        validate_password(value)

        return value