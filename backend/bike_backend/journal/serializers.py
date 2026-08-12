from rest_framework import serializers
from .models import JournalPost


class JournalPostListSerializer(serializers.ModelSerializer):
    cover_image = serializers.SerializerMethodField()

    class Meta:
        model = JournalPost
        fields = ['slug', 'title', 'category', 'excerpt', 'cover_image', 'author_name', 'read_time_minutes', 'published_at']

    def get_cover_image(self, obj):
        request = self.context.get('request')
        if not obj.cover_image:
            return ''
        return request.build_absolute_uri(obj.cover_image.url) if request else obj.cover_image.url


class JournalPostDetailSerializer(JournalPostListSerializer):
    class Meta(JournalPostListSerializer.Meta):
        fields = JournalPostListSerializer.Meta.fields + ['content']