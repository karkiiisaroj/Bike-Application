from django.contrib import admin
from .models import Booking


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):

    list_display = (
        "user",
        "bike",
        "dealer",
        "booking_date",
        "booking_time",
        "status",
    )

    list_filter = (
        "status",
        "booking_date",
        "dealer",
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