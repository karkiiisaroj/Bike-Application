from django.urls import path
from .views import JournalPostListView, JournalPostDetailView

urlpatterns = [
    path('posts/', JournalPostListView.as_view(), name='journal-list'),
    path('posts/<slug:slug>/', JournalPostDetailView.as_view(), name='journal-detail'),
]