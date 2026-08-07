from django.db import models


class StoryEntry(models.Model):
    entry_id = models.CharField(max_length=50, unique=True)  # matches Flutter's `id`
    year = models.CharField(max_length=4)
    era_key = models.CharField(max_length=20)
    description = models.TextField()
    order = models.PositiveIntegerField(default=0)  # keeps chronological order explicit

    class Meta:
        ordering = ['order']

    def __str__(self):
        return f"{self.year} — {self.entry_id}"