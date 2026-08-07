from django.contrib import admin
from .models import Rental


@admin.register(Rental)
class RentalAdmin(admin.ModelAdmin):

    list_display = (
        "user",
        "bike",
        "dealer",
        "pickup_date",
        "return_date",
        "status",
        "total_price",
    )

    list_filter = (
        "status",
        "dealer",
        "pickup_date",
    )

    search_fields = (
        "user__username",
        "bike__name",
        "dealer__name",
    )

    list_editable = (
        "status",
    )

    readonly_fields = (
        "created_at",
        "updated_at",
    )