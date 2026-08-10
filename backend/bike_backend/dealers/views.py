from rest_framework import generics, permissions
from .models import Dealer
from .serializers import DealerSerializer


class DealerListView(generics.ListAPIView):
    """GET /api/dealers/ — public, read-only."""
    queryset = Dealer.objects.all()
    serializer_class = DealerSerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None