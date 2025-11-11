#!/usr/bin/env bash
set -e

# Load environment variables from .env if it exists
if [ -f ".env" ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Function to wait for Postgres
wait_for_postgres() {
  echo "Waiting for Postgres at $POSTGRES_HOST:$POSTGRES_PORT..."
  until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q' 2>/dev/null; do
    echo "Postgres is unavailable - sleeping"
    sleep 2
  done
  echo "Postgres is up - continuing"
}

# Wait for Postgres to be ready
wait_for_postgres

# Run migrations and collect static files
python manage.py migrate --noinput
python manage.py collectstatic --noinput

# Create superuser if credentials provided
if [ -n "$DJANGO_SUPERUSER_EMAIL" ] && [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then
  echo "from django.contrib.auth import get_user_model; \
User = get_user_model(); \
if not User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists(): \
    User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME','$DJANGO_SUPERUSER_EMAIL','$DJANGO_SUPERUSER_PASSWORD')" \
  | python manage.py shell || true
fi

# Start Django server
exec python manage.py runserver 0.0.0.0:8000
