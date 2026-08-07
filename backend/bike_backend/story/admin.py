from django.contrib import admin
from .models import StoryEntry


@admin.register(StoryEntry)
class StoryEntryAdmin(admin.ModelAdmin):
    list_display = ['entry_id', 'year', 'order', 'era_key']
    list_editable = ['order']
    search_fields = ['entry_id', 'description']