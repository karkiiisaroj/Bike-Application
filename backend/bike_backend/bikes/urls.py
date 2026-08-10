from django.urls import path
from .views import BikeListView

urlpatterns = [
    path('', BikeListView.as_view(), name='bike-list'),
]