from django.contrib import admin
from .models import AppUser, Profile, BlacklistedToken


@admin.register(AppUser)
class AppUserAdmin(admin.ModelAdmin):
    list_display = (
        "username",
        "email",
        "first_name",
        "last_name",
        "is_active",
        "date_joined",
    )


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = (
        "user",
        "phone",
        "city",
        "created_at",
    )


@admin.register(BlacklistedToken)
class BlacklistedTokenAdmin(admin.ModelAdmin):
    list_display = (
        "jti",
        "blacklisted_at",
    )