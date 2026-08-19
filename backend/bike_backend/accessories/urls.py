from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import AccessoryViewSet, CreateOrderView, OrderDetailView

router = DefaultRouter()
router.register("", AccessoryViewSet, basename="accessory")

urlpatterns = [
    # Orders MUST come before the router: now that the router is
    # registered at "" (see below), its own detail pattern is
    # <anything>/ — which would otherwise swallow "orders/" and
    # "orders/<order_number>/" as if "orders" were an accessory slug.
    path("orders/", CreateOrderView.as_view(), name="create-order"),
    path("orders/<str:order_number>/", OrderDetailView.as_view(), name="order-detail"),
    path("", include(router.urls)),
]