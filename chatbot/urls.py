from django.urls import path
from . import views

urlpatterns = [
    path('', views.Index.as_view(), name='index'),  # <- note the .as_view()
    path('api/chat/', views.chat_api, name='chat_api'),
]
