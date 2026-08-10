from django.db import models


class Category(models.Model):
    """Matches bikeCategories in Flutter — slug values line up with
    categoryForBike's switch statement (heritage, scrambler,
    pure_sport, roadster, adventure, cruiser)."""
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