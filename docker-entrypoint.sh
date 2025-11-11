#!/usr/bin/env bash
set -e

# Load environment variables
if [ -f ".env" ]; then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

# Run migrations
python manage.py migrate --noinput

# Collect static files
python manage.py collectstatic --noinput

# Create superuser if environment variables exist
if [ -n "$DJANGO_SUPERUSER_EMAIL" ] && [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
  echo "from django.contrib.auth import get_user_model; User = get_user_model();
if not User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists():
    User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME','$DJANGO_SUPERUSER_EMAIL','$DJANGO_SUPERUSER_PASSWORD')" | python manage.py shell || true
fi

# Ensure DEBUG and ALLOWED_HOSTS are set
export DJANGO_ALLOWED_HOSTS=${DJANGO_ALLOWED_HOSTS:-*}
export DEBUG=${DEBUG:-1}

# Run server in foreground
exec python manage.py runserver 0.0.0.0:8000
