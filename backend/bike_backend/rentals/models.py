from django.db import models
from accounts.models import AppUser


class RentalCategory(models.Model):
    name = models.CharField(max_length=50)
    slug = models.SlugField(unique=True)  # hyphenated, e.g. 'pure-sport'

    class Meta:
        verbose_name_plural = 'Rental Categories'
        ordering = ['name']

    def __str__(self):
        return self.name


class RentalBike(models.Model):
    name = models.CharField(max_length=100)
    tagline = models.CharField(max_length=150, blank=True)
    category = models.ForeignKey(RentalCategory, on_delete=models.PROTECT, related_name='bikes')
    price_per_day = models.PositiveIntegerField(help_text='Price per day, in rupees')
    hero_image = models.ImageField(upload_to='rentals/hero/')
    is_active = models.BooleanField(
        default=True,
        help_text='Uncheck to hide from the rental fleet without deleting booking history tied to it',
    )

    class Meta:
        ordering = ['category__name', 'name']

    def __str__(self):
        return self.name


class RentalBooking(models.Model):
    class Status(models.TextChoices):
        CONFIRMED = 'confirmed', 'Confirmed'
        CANCELLED = 'cancelled', 'Cancelled'

    user = models.ForeignKey(AppUser, on_delete=models.CASCADE, related_name='rental_bookings')
    bike = models.ForeignKey(RentalBike, on_delete=models.PROTECT, related_name='bookings')
    start_date = models.DateField()
    end_date = models.DateField()
    total_price = models.PositiveIntegerField()
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.CONFIRMED)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.bike.name} — {self.user.username} ({self.start_date} to {self.end_date})'