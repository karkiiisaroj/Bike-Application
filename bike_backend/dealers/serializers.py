from rest_framework import serializers
from .models import Dealer

class DealerSerializer(serializers.ModelSerializer):

    google_maps = serializers.SerializerMethodField()

    class Meta:
        model = Dealer
        fields = "__all__"

    def get_google_maps(self, obj):
        return f"https://www.google.com/maps?q={obj.latitude},{obj.longitude}"