from rest_framework import serializers
from django.utils import timezone
from .models import RentalCategory, RentalBike, RentalBooking


class RentalCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = RentalCategory
        fields = ['slug', 'name']


class RentalBikeSerializer(serializers.ModelSerializer):
    category = RentalCategorySerializer(read_only=True)
    hero_image = serializers.SerializerMethodField()

    class Meta:
        model = RentalBike
        fields = ['id', 'name', 'tagline', 'category', 'price_per_day', 'hero_image']

    def get_hero_image(self, obj):
        request = self.context.get('request')
        if not obj.hero_image:
            return ''
        return request.build_absolute_uri(obj.hero_image.url) if request else obj.hero_image.url


class BookedRangeSerializer(serializers.ModelSerializer):
    """Public — dates only, no user info, so the app can grey out
    unavailable days without leaking whose booking it is."""

    class Meta:
        model = RentalBooking
        fields = ['start_date', 'end_date']


class RentalBookingSerializer(serializers.ModelSerializer):
    bike_detail = RentalBikeSerializer(source='bike', read_only=True)

    class Meta:
        model = RentalBooking
        fields = ['id', 'bike', 'bike_detail', 'start_date', 'end_date', 'total_price', 'status', 'created_at']
        read_only_fields = ['id', 'bike_detail', 'total_price', 'status', 'created_at']

    def validate(self, attrs):
        bike = attrs['bike']
        start = attrs['start_date']
        end = attrs['end_date']

        if end < start:
            raise serializers.ValidationError('End date must be on or after the start date.')
        if start < timezone.localdate():
            raise serializers.ValidationError('Start date cannot be in the past.')

        overlapping = RentalBooking.objects.filter(
            bike=bike,
            status=RentalBooking.Status.CONFIRMED,
            start_date__lte=end,
            end_date__gte=start,
        )
        if overlapping.exists():
            raise serializers.ValidationError('This bike is already booked for part of that date range.')

        return attrs

    def create(self, validated_data):
        bike = validated_data['bike']
        start = validated_data['start_date']
        end = validated_data['end_date']
        days = (end - start).days + 1

        return RentalBooking.objects.create(
            user=self.context['request'].user,
            bike=bike,
            start_date=start,
            end_date=end,
            total_price=bike.price_per_day * days,
            status=RentalBooking.Status.CONFIRMED,
        )