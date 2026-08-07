from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import GarageViewSet

router = DefaultRouter()

router.register(
    "garage",
    GarageViewSet,
    basename="garage"
)

urlpatterns = [
    path("", include(router.urls)),
]