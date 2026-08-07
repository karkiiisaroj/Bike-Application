from rest_framework import serializers
from .models import StoryEntry


class StoryEntrySerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='entry_id')

    class Meta:
        model = StoryEntry
        fields = ['id', 'year', 'era_key', 'description']