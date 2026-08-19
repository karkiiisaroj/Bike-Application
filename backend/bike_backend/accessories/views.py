from rest_framework import generics, status, viewsets
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

from .models import Accessory, Order
from .serializers import (
    AccessoryDetailSerializer,
    AccessoryListSerializer,
    CreateOrderSerializer,
    OrderSerializer,
)


class AccessoryViewSet(viewsets.ReadOnlyModelViewSet):
    """
    GET /api/accessories/
        -> everything active

    GET /api/accessories/?category=heritage
        -> one segment (matches the old pill-bar filter)

    GET /api/accessories/?bike=Classic 350&category=heritage
        -> accessories explicitly fitted to that bike; if none are
           tagged yet, falls back to showing the whole category so the
           page is never empty — same behaviour the old
           BikeAccessoriesScreen used to do client-side, now centralised
           here so every client (Flutter, future web, etc.) gets it for
           free.

    GET /api/accessories/<slug>/
        -> full detail, including description, stock and fitted bikes
    """

    queryset = Accessory.objects.filter(is_active=True)
    lookup_field = "slug"
    permission_classes = [AllowAny]
    authentication_classes = []  # public browse/detail — skip CustomJWTAuthentication entirely

    def get_serializer_class(self):
        if self.action == "retrieve":
            return AccessoryDetailSerializer
        return AccessoryListSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        category = self.request.query_params.get("category")
        bike = self.request.query_params.get("bike")

        if bike:
            fitted = qs.filter(fitments__bike_name__iexact=bike).distinct()
            if fitted.exists():
                return fitted
            return qs.filter(category=category) if category else qs.none()

        if category:
            return qs.filter(category=category)

        return qs


class CreateOrderView(generics.CreateAPIView):
    """POST /api/orders/ — place an order from the current cart."""

    serializer_class = CreateOrderSerializer
    permission_classes = [AllowAny]
    authentication_classes = []  # guest checkout — skip CustomJWTAuthentication entirely

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        order = serializer.save()
        return Response(
            OrderSerializer(order, context={"request": request}).data,
            status=status.HTTP_201_CREATED,
        )


class OrderDetailView(generics.RetrieveAPIView):
    """GET /api/orders/<order_number>/ — order status lookup, works for
    guest checkouts since it's keyed by the order number, not the user."""

    queryset = Order.objects.all()
    serializer_class = OrderSerializer
    permission_classes = [AllowAny]
    authentication_classes = []  # order lookup by number, no login required
    lookup_field = "order_number"