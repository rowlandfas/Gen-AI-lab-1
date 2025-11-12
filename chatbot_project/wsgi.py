import os
from django.core.wsgi import get_wsgi_application

# Set the settings module for Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'chatbot_project.settings')

# Create the WSGI application object that Gunicorn will use
application = get_wsgi_application()
