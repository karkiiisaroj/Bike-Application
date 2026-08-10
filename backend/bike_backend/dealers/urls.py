from django.urls import path
from .views import DealerListView

urlpatterns = [
    path('', DealerListView.as_view(), name='dealer-list'),
]