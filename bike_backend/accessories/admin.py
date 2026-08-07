from django.contrib import admin
from .models import (
    AccessoryCategory,
    Accessory,
    AccessoryImage,
)


@admin.register(AccessoryCategory)
class AccessoryCategoryAdmin(admin.ModelAdmin):

    list_display = (
        "name",
        "slug",
    )

    search_fields = (
        "name",
    )

    prepopulated_fields = {
        "slug": ("name",)
    }


@admin.register(Accessory)
class AccessoryAdmin(admin.ModelAdmin):

    list_display = (
        "name",
        "category",
        "price",
        "stock",
        "is_available",
    )

    list_filter = (
        "category",
        "is_available",
    )

    search_fields = (
        "name",
    )

    filter_horizontal = (
        "compatible_bikes",
    )

    list_editable = (
        "stock",
        "is_available",
    )

    prepopulated_fields = {
        "slug": ("name",)
    }

    readonly_fields = (
        "created_at",
        "updated_at",
    )


@admin.register(AccessoryImage)
class AccessoryImageAdmin(admin.ModelAdmin):

    list_display = (
        "accessory",
        "display_order",
    )

    ordering = (
        "accessory",
        "display_order",
    )