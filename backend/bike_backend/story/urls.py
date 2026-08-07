from django.urls import path
from .views import StoryEntryListView

urlpatterns = [
    path('entries/', StoryEntryListView.as_view(), name='story-entries'),
]