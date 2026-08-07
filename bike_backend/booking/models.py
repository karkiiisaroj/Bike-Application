from django.db import models
from django.conf import settings
from bikes.models import Bike
from dealers.models import Dealer


class Booking(models.Model):

    BOOKING_TYPES = (
        ("test_ride", "Test Ride"),
        ("showroom_visit", "Showroom Visit"),
    )

    STATUS_CHOICES = (
        ("pending", "Pending"),
        ("confirmed", "Confirmed"),
        ("completed", "Completed"),
        ("cancelled", "Cancelled"),
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="bookings"
    )

    bike = models.ForeignKey(
        Bike,
        on_delete=models.CASCADE,
        related_name="bookings"
    )

    dealer = models.ForeignKey(
        Dealer,
        on_delete=models.CASCADE,
        related_name="bookings"
    )

    booking_type = models.CharField(
        max_length=20,
        choices=BOOKING_TYPES,
        default="test_ride"
    )

    booking_date = models.DateField()

    booking_time = models.TimeField()

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default="pending"
    )

    remarks = models.TextField(
        blank=True,
        null=True
    )

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    updated_at = models.DateTimeField(
        auto_now=True
    )

    class Meta:
        ordering = ["-booking_date", "-booking_time"]

    def __str__(self):
        return f"{self.user} - {self.bike.name}"