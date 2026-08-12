from rest_framework import generics, permissions
from .models import JournalPost
from .serializers import JournalPostListSerializer, JournalPostDetailSerializer


class JournalPostListView(generics.ListAPIView):
    """GET /api/journal/posts/ — public."""
    queryset = JournalPost.objects.filter(is_published=True)
    serializer_class = JournalPostListSerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None


class JournalPostDetailView(generics.RetrieveAPIView):
    """GET /api/journal/posts/<slug>/ — public."""
    queryset = JournalPost.objects.filter(is_published=True)
    serializer_class = JournalPostDetailSerializer
    permission_classes = [permissions.AllowAny]
    lookup_field = 'slug'