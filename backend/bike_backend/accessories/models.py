import random
import string

from django.conf import settings
from django.core.validators import MinValueValidator
from django.db import models
from django.utils.text import slugify


class AccessoryCategory(models.TextChoices):
    """Same six segment ids used across the rest of the app (bike
    folders, the old local catalog, the Flutter pill bar)."""
    HERITAGE = "heritage", "Heritage"
    ADVENTURE = "adventure", "Adventure"
    ROADSTER = "roadster", "Roadster"
    CRUISER = "cruiser", "Cruiser"
    SCRAMBLER = "scrambler", "Scrambler"
    PURE_SPORT = "pure-sport", "Pure-Sport"


def accessory_image_path(instance, filename):
    return f"accessories/{instance.category}/{filename}"


class Accessory(models.Model):
    name = models.CharField(max_length=120)
    slug = models.SlugField(max_length=140, unique=True, blank=True)
    description = models.TextField(blank=True)
    price = models.PositiveIntegerField(help_text="Price in whole ₹")
    category = models.CharField(max_length=20, choices=AccessoryCategory.choices)
    image = models.ImageField(upload_to=accessory_image_path, blank=True, null=True)
    stock = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["category", "name"]
        verbose_name_plural = "Accessories"

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        if not self.slug:
            base = slugify(self.name)
            slug = base
            n = 1
            while Accessory.objects.filter(slug=slug).exclude(pk=self.pk).exists():
                n += 1
                slug = f"{base}-{n}"
            self.slug = slug
        super().save(*args, **kwargs)

    @property
    def in_stock(self):
        return self.stock > 0


class AccessoryFitment(models.Model):
    """
    One row = this accessory fits this bike, matched by exact bike name
    (the same string as Bike.name / BikeData.name on the Flutter side).

    Kept as a plain name string rather than an FK so this app doesn't
    need to import or depend on wherever your Bike model lives — drop
    it in as its own app and point the frontend at it.
    """

    accessory = models.ForeignKey(
        Accessory, related_name="fitments", on_delete=models.CASCADE
    )
    bike_name = models.CharField(max_length=120)

    class Meta:
        unique_together = ("accessory", "bike_name")

    def __str__(self):
        return f"{self.accessory.name} → {self.bike_name}"


class Order(models.Model):
    class PaymentMethod(models.TextChoices):
        COD = "cod", "Cash on Delivery"
        ESEWA = "esewa", "eSewa"
        KHALTI = "khalti", "Khalti"

    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        CONFIRMED = "confirmed", "Confirmed"
        SHIPPED = "shipped", "Shipped"
        DELIVERED = "delivered", "Delivered"
        CANCELLED = "cancelled", "Cancelled"

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="accessory_orders",
    )
    order_number = models.CharField(max_length=20, unique=True, editable=False)
    customer_name = models.CharField(max_length=120)
    phone = models.CharField(max_length=20)
    email = models.EmailField(blank=True)
    address = models.CharField(max_length=255)
    city = models.CharField(max_length=80)
    payment_method = models.CharField(
        max_length=10, choices=PaymentMethod.choices, default=PaymentMethod.COD
    )
    status = models.CharField(
        max_length=12, choices=Status.choices, default=Status.PENDING
    )
    total_price = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def save(self, *args, **kwargs):
        if not self.order_number:
            self.order_number = self._generate_order_number()
        super().save(*args, **kwargs)

    @staticmethod
    def _generate_order_number():
        return "RE-" + "".join(random.choices(string.digits, k=8))

    def __str__(self):
        return self.order_number


class OrderItem(models.Model):
    order = models.ForeignKey(Order, related_name="items", on_delete=models.CASCADE)
    accessory = models.ForeignKey(
        Accessory, related_name="order_items", on_delete=models.PROTECT
    )
    quantity = models.PositiveIntegerField(default=1, validators=[MinValueValidator(1)])
    unit_price = models.PositiveIntegerField(help_text="Snapshot of price at purchase time")

    @property
    def subtotal(self):
        return self.unit_price * self.quantity

    def __str__(self):
        return f"{self.quantity} × {self.accessory.name}"