from rest_framework import serializers
from .models import Category, Bike, BikeColorVariant, BikeFrame


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['slug', 'name']


class BikeSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    hero_image = serializers.SerializerMethodField()

    class Meta:
        model = Bike
        fields = ['id', 'name', 'category', 'hero_image']

    def get_hero_image(self, obj):
        # Return an absolute URL (http://127.0.0.1:8000/media/...) so
        # Image.network() in Flutter can load it directly — a relative
        # path like "/media/bikes/hero/x.jpg" won't resolve on its own.
        request = self.context.get('request')
        if not obj.hero_image:
            return ''
        return request.build_absolute_uri(obj.hero_image.url) if request else obj.hero_image.url

class BikeFrameSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()

    class Meta:
        model = BikeFrame
        fields = ['frame_number', 'image']

    def get_image(self, obj):
        request = self.context.get('request')
        return request.build_absolute_uri(obj.image.url) if request else obj.image.url


class BikeColorVariantSerializer(serializers.ModelSerializer):
    tank_image = serializers.SerializerMethodField()
    frames = BikeFrameSerializer(many=True, read_only=True)

    class Meta:
        model = BikeColorVariant
        fields = ['id', 'name', 'tank_image', 'order', 'frames']

    def get_tank_image(self, obj):
        request = self.context.get('request')

        if not obj.tank_image:
            return ''

        return (
            request.build_absolute_uri(obj.tank_image.url)
            if request
            else obj.tank_image.url
        )
