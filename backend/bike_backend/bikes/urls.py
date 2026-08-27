from django.urls import path
from bikes.views import upload_frames_page
from .views import BikeListView, BikeColorVariantListView

urlpatterns = [
    path('', BikeListView.as_view(), name='bike-list'),
    path('<int:bike_id>/color-variants/', BikeColorVariantListView.as_view(), name='bike-color-variants'),
    path('upload-frames/', upload_frames_page, name='upload-frames'),
]