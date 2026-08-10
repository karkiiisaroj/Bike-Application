from rest_framework import generics, permissions
from .models import Bike
from .serializers import BikeSerializer


class BikeListView(generics.ListAPIView):
    """GET /api/bikes/ — public, read-only."""
    queryset = Bike.objects.select_related('category').all()
    serializer_class = BikeSerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None  # matches Bike.fromJson expecting a bare list