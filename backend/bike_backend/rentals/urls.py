from django.urls import path
from .views import BookingCancelView, RentalBikeListView, BikeAvailabilityView, RentalBookingCreateView, MyBookingsView

urlpatterns = [
    path('bikes/', RentalBikeListView.as_view(), name='rental-bike-list'),
    path('bikes/<int:bike_id>/availability/', BikeAvailabilityView.as_view(), name='rental-bike-availability'),
    path('bookings/', RentalBookingCreateView.as_view(), name='rental-booking-create'),
    path('bookings/mine/', MyBookingsView.as_view(), name='rental-booking-mine'),
    path('bookings/<int:pk>/cancel/', BookingCancelView.as_view(), name='rental-booking-cancel'),
]