from django.db import models
from django.conf import settings
from bikes.models import Bike


class Garage(models.Model):

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="garage"
    )

    bike = models.ForeignKey(
        Bike,
        on_delete=models.CASCADE,
        related_name="garage_entries"
    )

    registration_number = models.CharField(
        max_length=30,
        unique=True
    )

    chassis_number = models.CharField(
        max_length=50,
        blank=True
    )

    engine_number = models.CharField(
        max_length=50,
        blank=True
    )

    purchase_date = models.DateField()

    current_mileage = models.PositiveIntegerField(
        help_text="Current mileage in KM"
    )

    color = models.CharField(
        max_length=50,
        blank=True
    )

    is_primary = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)

    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        unique_together = ("user", "bike", "registration_number")

    def __str__(self):
        return f"{self.user} - {self.bike.name}"