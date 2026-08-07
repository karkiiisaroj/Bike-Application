from django.contrib import admin
from .models import Garage


@admin.register(Garage)
class GarageAdmin(admin.ModelAdmin):

    list_display = (
        "user",
        "bike",
        "registration_number",
        "current_mileage",
        "purchase_date",
        "is_primary",
    )

    list_filter = (
        "bike",
        "is_primary",
    )

    search_fields = (
        "user__username",
        "bike__name",
        "registration_number",
    )

    list_editable = (
        "is_primary",
    )

    readonly_fields = (
        "created_at",
        "updated_at",
    )