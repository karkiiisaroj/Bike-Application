from django.db import models


class Category(models.Model):
    name = models.CharField(max_length=50)
    slug = models.SlugField(unique=True)

    class Meta:
        verbose_name_plural = 'Categories'
        ordering = ['name']

    def __str__(self):
        return self.name


class Bike(models.Model):
    name = models.CharField(max_length=100)
    category = models.ForeignKey(Category, on_delete=models.PROTECT, related_name='bikes')
    hero_image = models.ImageField(upload_to='bikes/hero/')

    class Meta:
        ordering = ['name']

    def __str__(self):
        return self.name


class BikeColorVariant(models.Model):
    """One tank-colour option for a bike — 'Ventura Blue', 'Asphalt
    Black', etc. Each variant has its own full 36-frame spin set."""
    bike = models.ForeignKey(Bike, on_delete=models.CASCADE, related_name='color_variants')
    name = models.CharField(max_length=60)
    tank_image = models.ImageField(
        upload_to='bike_tanks/',
        null=True,
        blank=True
    )
    order = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ['order', 'id']

    def __str__(self):
        return f'{self.bike.name} — {self.name}'

    @property
    def frame_count(self):
        return self.frames.count()


class BikeFrame(models.Model):
    """One frame (1-36) of a colour variant's 360° spin set."""
    variant = models.ForeignKey(BikeColorVariant, on_delete=models.CASCADE, related_name='frames')
    frame_number = models.PositiveSmallIntegerField()
    image = models.ImageField(upload_to='bikes/360/')

    class Meta:
        ordering = ['frame_number']
        unique_together = ('variant', 'frame_number')

    def __str__(self):
        return f'{self.variant} — frame {self.frame_number}'