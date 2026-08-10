from django.contrib import admin
from .models import Category, Bike


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'slug']
    prepopulated_fields = {'slug': ('name',)}


@admin.register(Bike)
class BikeAdmin(admin.ModelAdmin):
    list_display = ['name', 'category']
    list_filter = ['category']