from django.contrib import admin
from .models import RentalCategory, RentalBike, RentalBooking


@admin.register(RentalCategory)
class RentalCategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'slug']
    prepopulated_fields = {'slug': ('name',)}


@admin.register(RentalBike)
class RentalBikeAdmin(admin.ModelAdmin):
    list_display = ['name', 'category', 'price_per_day', 'is_active']
    list_filter = ['category', 'is_active']
    list_editable = ['is_active']


@admin.register(RentalBooking)
class RentalBookingAdmin(admin.ModelAdmin):
    list_display = ['bike', 'user', 'start_date', 'end_date', 'status', 'total_price']
    list_filter = ['status', 'bike']
    search_fields = ['user__username', 'bike__name']