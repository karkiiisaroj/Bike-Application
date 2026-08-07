from rest_framework import generics, permissions
from .models import StoryEntry
from .serializers import StoryEntrySerializer


class StoryEntryListView(generics.ListAPIView):
    """GET /api/story/entries/ — public, read-only."""
    queryset = StoryEntry.objects.all()
    serializer_class = StoryEntrySerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None  # small fixed dataset — send it all at once