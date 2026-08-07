from django.db import models
from bikes.models import Bike


class AccessoryCategory(models.Model):
    name = models.CharField(max_length=100)
    slug = models.SlugField(unique=True)

    class Meta:
        ordering = ["name"]
        verbose_name_plural = "Accessory Categories"

    def __str__(self):
        return self.name


class Accessory(models.Model):

    category = models.ForeignKey(
        AccessoryCategory,
        on_delete=models.CASCADE,
        related_name="accessories"
    )

    compatible_bikes = models.ManyToManyField(
        Bike,
        related_name="accessories"
    )

    name = models.CharField(max_length=150)

    slug = models.SlugField(unique=True)

    short_description = models.CharField(max_length=255)

    description = models.TextField()

    price = models.DecimalField(
        max_digits=10,
        decimal_places=2
    )

    image = models.ImageField(
        upload_to="accessories/"
    )

    stock = models.PositiveIntegerField(default=0)

    is_available = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)

    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["name"]

    def __str__(self):
        return self.name


class AccessoryImage(models.Model):

    accessory = models.ForeignKey(
        Accessory,
        on_delete=models.CASCADE,
        related_name="images"
    )

    image = models.ImageField(
        upload_to="accessories/gallery/"
    )

    display_order = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ["display_order"]

    def __str__(self):
        return f"{self.accessory.name} Image {self.display_order}"