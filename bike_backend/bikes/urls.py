from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import (
    BikeCategoryViewSet,
    BikeViewSet,
    BikeColorViewSet,
    BikeSpecificationViewSet,
)

router = DefaultRouter()

router.register(
    "categories",
    BikeCategoryViewSet
)

router.register(
    "bikes",
    BikeViewSet
)

router.register(
    "colors",
    BikeColorViewSet
)

router.register(
    "specifications",
    BikeSpecificationViewSet
)

urlpatterns = [
    path("", include(router.urls)),
]