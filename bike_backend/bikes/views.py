from rest_framework import viewsets
from .models import (
    BikeCategory,
    Bike,
    BikeColor,
    BikeSpecification,
)

from .serializers import (
    BikeCategorySerializer,
    BikeSerializer,
    BikeColorSerializer,
    BikeSpecificationSerializer,
)


class BikeCategoryViewSet(viewsets.ModelViewSet):

    queryset = BikeCategory.objects.all()

    serializer_class = BikeCategorySerializer


class BikeViewSet(viewsets.ModelViewSet):

    queryset = Bike.objects.all()

    serializer_class = BikeSerializer


class BikeColorViewSet(viewsets.ModelViewSet):

    queryset = BikeColor.objects.all()

    serializer_class = BikeColorSerializer


class BikeSpecificationViewSet(viewsets.ModelViewSet):

    queryset = BikeSpecification.objects.all()

    serializer_class = BikeSpecificationSerializer