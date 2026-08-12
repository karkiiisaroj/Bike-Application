from django.db import models


class JournalPost(models.Model):
    class Category(models.TextChoices):
        RIDE_REPORT = 'ride_report', 'Ride Report'
        HERITAGE = 'heritage', 'Heritage'
        GEAR_GUIDE = 'gear_guide', 'Gear Guide'

    title = models.CharField(max_length=200)
    slug = models.SlugField(unique=True)
    category = models.CharField(max_length=20, choices=Category.choices)
    excerpt = models.CharField(max_length=280, help_text='Short teaser shown on the journal list')
    content = models.TextField(help_text='Full article body. Separate paragraphs with a blank line.')
    cover_image = models.ImageField(upload_to='journal/covers/')
    author_name = models.CharField(max_length=100, default='Royal Enfield')
    read_time_minutes = models.PositiveSmallIntegerField(default=4)
    published_at = models.DateField()
    is_published = models.BooleanField(default=True)

    class Meta:
        ordering = ['-published_at']

    def __str__(self):
        return self.title