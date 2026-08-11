from rest_framework import generics, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import RentalBike, RentalBooking
from .serializers import RentalBikeSerializer, BookedRangeSerializer, RentalBookingSerializer


class RentalBikeListView(generics.ListAPIView):
    """GET /api/rentals/bikes/ — public. Only shows active bikes."""
    queryset = RentalBike.objects.filter(is_active=True).select_related('category')
    serializer_class = RentalBikeSerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None


class BikeAvailabilityView(generics.ListAPIView):
    """GET /api/rentals/bikes/<id>/availability/ — public. Every
    confirmed booking's date range for this bike."""
    serializer_class = BookedRangeSerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None

    def get_queryset(self):
        return RentalBooking.objects.filter(
            bike_id=self.kwargs['bike_id'],
            status=RentalBooking.Status.CONFIRMED,
        )


class RentalBookingCreateView(generics.CreateAPIView):
    """POST /api/rentals/bookings/ — requires auth. Rejects overlapping
    date ranges via the serializer's validate()."""
    serializer_class = RentalBookingSerializer
    permission_classes = [permissions.IsAuthenticated]


class MyBookingsView(generics.ListAPIView):
    """GET /api/rentals/bookings/mine/ — requires auth. This user's
    booking history, most recent first."""
    serializer_class = RentalBookingSerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None

    def get_queryset(self):
        return RentalBooking.objects.filter(user=self.request.user).select_related('bike', 'bike__category')


class BookingCancelView(APIView):
    """PATCH /api/rentals/bookings/<id>/cancel/ — requires auth. Only
    the booking's own owner can cancel it, and only while it's still
    confirmed (can't "cancel" an already-cancelled booking)."""
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        booking = RentalBooking.objects.filter(pk=pk, user=request.user).first()
        if not booking:
            return Response({'detail': 'Booking not found.'}, status=status.HTTP_404_NOT_FOUND)
        if booking.status != RentalBooking.Status.CONFIRMED:
            return Response({'detail': 'This booking is already cancelled.'}, status=status.HTTP_400_BAD_REQUEST)

        booking.status = RentalBooking.Status.CANCELLED
        booking.save()
        return Response(RentalBookingSerializer(booking, context={'request': request}).data)