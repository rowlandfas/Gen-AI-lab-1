FROM python:3.10-slim

# Install netcat for waiting on Postgres
RUN apt-get update && apt-get install -y netcat-traditional && rm -rf /var/lib/apt/lists/*

WORKDIR /code

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy project files
COPY . .
RUN chmod +x /code/docker-entrypoint.sh

# Entrypoint
ENTRYPOINT ["/code/docker-entrypoint.sh"]

