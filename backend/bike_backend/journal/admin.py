from django.contrib import admin
from .models import JournalPost


@admin.register(JournalPost)
class JournalPostAdmin(admin.ModelAdmin):
    list_display = ['title', 'category', 'published_at', 'is_published']
    list_filter = ['category', 'is_published']
    prepopulated_fields = {'slug': ('title',)}
    search_fields = ['title', 'excerpt']