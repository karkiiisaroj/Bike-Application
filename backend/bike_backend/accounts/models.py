from django.conf import settings
from django.db import models


class AppUser(models.Model):
    """A completely standalone user table — no relation to Django's
    built-in auth_user, no AbstractUser, no PermissionsMixin."""
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(unique=True)
    first_name = models.CharField(max_length=150, blank=True)
    last_name = models.CharField(max_length=150, blank=True)
    password_hash = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)
    date_joined = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.username

    @property
    def is_authenticated(self):
        # DRF permission checks look for this attribute on request.user
        return True


class Profile(models.Model):
    user = models.OneToOneField(
        AppUser,
        on_delete=models.CASCADE,
        related_name='profile'
    )
    phone = models.CharField(max_length=20, blank=True)
    address = models.CharField(max_length=255, blank=True)
    city = models.CharField(max_length=100, blank=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True)
    date_of_birth = models.DateField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username}'s profile"


class BlacklistedToken(models.Model):
    """Lets logout actually invalidate a refresh token — plain JWTs
    can't be revoked otherwise, since they're stateless by design."""
    jti = models.CharField(max_length=64, unique=True)
    blacklisted_at = models.DateTimeField(auto_now_add=True)