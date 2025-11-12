FROM python:3.10-slim

# Install netcat to wait for Postgres
RUN apt-get update && apt-get install -y netcat-traditional && rm -rf /var/lib/apt/lists/*

WORKDIR /code
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
