from django.contrib import admin
from .models import (
    BikeCategory,
    Bike,
    BikeImage,
    BikeColor,
    BikeFrame,
    BikeSpecification,
    BikeFeature,
)


@admin.register(BikeCategory)
class BikeCategoryAdmin(admin.ModelAdmin):
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


@admin.register(Bike)
class BikeAdmin(admin.ModelAdmin):

    list_display = (
        "name",
        "category",
        "price",
        "is_available",
        "created_at",
    )

    list_filter = (
        "category",
        "is_available",
    )

    search_fields = (
        "name",
        "short_description",
    )

    list_editable = (
        "is_available",
    )

    prepopulated_fields = {
        "slug": ("name",)
    }

    readonly_fields = (
        "created_at",
        "updated_at",
    )


@admin.register(BikeImage)
class BikeImageAdmin(admin.ModelAdmin):

    list_display = (
        "bike",
        "image_type",
        "display_order",
    )

    list_filter = (
        "image_type",
    )

    ordering = (
        "bike",
        "display_order",
    )


@admin.register(BikeColor)
class BikeColorAdmin(admin.ModelAdmin):

    list_display = (
        "bike",
        "name",
        "color_code",
    )

    list_filter = (
        "bike",
    )

    search_fields = (
        "name",
    )


@admin.register(BikeFrame)
class BikeFrameAdmin(admin.ModelAdmin):

    list_display = (
        "color",
        "frame_order",
    )

    ordering = (
        "color",
        "frame_order",
    )


@admin.register(BikeSpecification)
class BikeSpecificationAdmin(admin.ModelAdmin):

    list_display = (
        "bike",
        "engine",
        "max_power",
        "max_torque",
    )

    search_fields = (
        "bike__name",
    )


@admin.register(BikeFeature)
class BikeFeatureAdmin(admin.ModelAdmin):

    list_display = (
        "bike",
        "title",
    )

    search_fields = (
        "bike__name",
        "title",
    )