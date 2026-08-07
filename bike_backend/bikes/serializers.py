from rest_framework import serializers

from .models import (
    BikeCategory,
    Bike,
    BikeColor,
    BikeFrame,
    BikeSpecification,
)

class BikeCategorySerializer(serializers.ModelSerializer):

    image = serializers.SerializerMethodField()

    class Meta:
        model = BikeCategory
        fields = "__all__"

    def get_image(self, obj):
        request = self.context.get("request")

        if obj.image:
            return request.build_absolute_uri(obj.image.url)

        return None

class BikeFrameSerializer(serializers.ModelSerializer):
    class Meta:
        model = BikeFrame
        fields = "__all__"


class BikeSpecificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = BikeSpecification
        fields = "__all__"


class BikeColorSerializer(serializers.ModelSerializer):

    frames = BikeFrameSerializer(
        many=True,
        read_only=True
    )

    class Meta:
        model = BikeColor
        fields = "__all__"

class BikeSerializer(serializers.ModelSerializer):
    hero_image = serializers.SerializerMethodField()
    category = BikeCategorySerializer(read_only=True)

    class Meta:
        model = Bike
        fields = "__all__"

    def get_hero_image(self, obj):
        request = self.context.get("request")

        if obj.hero_image:
            return request.build_absolute_uri(obj.hero_image.url)

        return None