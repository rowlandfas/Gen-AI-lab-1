#!/usr/bin/env bash
set -e
# load .env into environment for Django to see DATABASE_URL or other envs if you like
if [ -f ".env" ]; then
export $(cat .env | sed 's/#.*//g' | xargs)
fi
python manage.py migrate --noinput
python manage.py collectstatic --noinput
# create superuser if env provided (optional)
if [ -n "$DJANGO_SUPERUSER_EMAIL" ] && [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
echo "from django.contrib.auth import get_user_model; User = get_user_model();
if not User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME','$DJANGO_SUPERUSER_EMAIL','$DJANGO_SUPERUSER_PASSWORD')" | python manage.py shell || true
fi
# run server
gunicorn chatbot_project.wsgi:application --bind 0.0.0.0:8000
