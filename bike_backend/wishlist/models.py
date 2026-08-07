from django.db import models
from django.conf import settings
from bikes.models import Bike
from accessories.models import Accessory


class Wishlist(models.Model):

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="wishlist"
    )

    bike = models.ForeignKey(
        Bike,
        on_delete=models.CASCADE,
        related_name="wishlisted_bikes",
        blank=True,
        null=True
    )

    accessory = models.ForeignKey(
        Accessory,
        on_delete=models.CASCADE,
        related_name="wishlisted_accessories",
        blank=True,
        null=True
    )

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    class Meta:
        ordering = ["-created_at"]

        constraints = [
        models.UniqueConstraint(
            fields=["user", "bike"],
            name="unique_user_bike_wishlist",
        ),
        models.UniqueConstraint(
            fields=["user", "accessory"],
            name="unique_user_accessory_wishlist",
        ),
    ]

    def __str__(self):
        if self.bike:
            return f"{self.user} - {self.bike.name}"

        return f"{self.user} - {self.accessory.name}"