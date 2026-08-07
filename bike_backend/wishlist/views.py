from rest_framework import viewsets

from .models import Wishlist
from .serializers import (
    WishlistListSerializer,
    WishlistDetailSerializer,
)


class WishlistViewSet(viewsets.ModelViewSet):

    queryset = Wishlist.objects.all()

    def get_serializer_class(self):

        if self.action == "list":
            return WishlistListSerializer

        return WishlistDetailSerializer