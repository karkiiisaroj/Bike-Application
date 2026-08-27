from django.shortcuts import render
from rest_framework import generics, permissions
from .models import Bike, BikeColorVariant
from .serializers import BikeSerializer, BikeColorVariantSerializer


class BikeListView(generics.ListAPIView):
    """GET /api/bikes/ — public, read-only."""
    queryset = Bike.objects.select_related('category').all()
    serializer_class = BikeSerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None  # matches Bike.fromJson expecting a bare list

class BikeColorVariantListView(generics.ListAPIView):
    """GET /api/bikes/<bike_id>/color-variants/ — public. Each variant
    comes with its full ordered frame list."""
    serializer_class = BikeColorVariantSerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None

    def get_queryset(self):
        return BikeColorVariant.objects.filter(bike_id=self.kwargs['bike_id']).prefetch_related('frames')

def upload_frames_page(request):
    return render(request, 'bikes/upload_frames.html')