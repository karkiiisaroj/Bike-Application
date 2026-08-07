from django.db import models
from django.conf import settings
from bikes.models import Bike
from dealers.models import Dealer


class Rental(models.Model):

    STATUS_CHOICES = (
        ("pending", "Pending"),
        ("approved", "Approved"),
        ("active", "Active"),
        ("completed", "Completed"),
        ("cancelled", "Cancelled"),
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="rentals"
    )

    bike = models.ForeignKey(
        Bike,
        on_delete=models.CASCADE,
        related_name="rentals"
    )

    dealer = models.ForeignKey(
        Dealer,
        on_delete=models.CASCADE,
        related_name="rentals"
    )

    pickup_date = models.DateField()

    return_date = models.DateField()

    pickup_time = models.TimeField()

    total_days = models.PositiveIntegerField()

    price_per_day = models.DecimalField(
        max_digits=10,
        decimal_places=2
    )

    total_price = models.DecimalField(
        max_digits=12,
        decimal_places=2
    )

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default="pending"
    )

    notes = models.TextField(
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
        ordering = ["-pickup_date"]

    def __str__(self):
        return f"{self.user} - {self.bike.name}"