from rest_framework import viewsets

from .models import Garage

from .serializers import (
    GarageListSerializer,
    GarageDetailSerializer,
)


class GarageViewSet(viewsets.ModelViewSet):

    queryset = Garage.objects.all()

    def get_serializer_class(self):

        if self.action == "list":
            return GarageListSerializer

        return GarageDetailSerializer