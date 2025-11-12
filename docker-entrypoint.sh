#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
echo "Waiting for Postgres..."
while ! nc -z db 5432; do
  sleep 1
done
echo "PostgreSQL started."

# Run migrations and collect static files
python manage.py migrate --noinput
python manage.py collectstatic --noinput

# Start the Gunicorn server
exec gunicorn chatbot_project.wsgi:application --bind 0.0.0.0:8000

