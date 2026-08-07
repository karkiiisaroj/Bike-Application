from django.contrib import admin
from .models import Dealer


@admin.register(Dealer)
class DealerAdmin(admin.ModelAdmin):

    list_display = (
        "name",
        "city",
        "phone",
        "is_active",
    )

    list_filter = (
        "city",
        "is_active",
    )

    search_fields = (
        "name",
        "city",
        "phone",
    )

    prepopulated_fields = {
        "slug": ("name",)
    }