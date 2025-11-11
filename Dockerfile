FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /code

# Install dependencies
RUN apt-get update && apt-get install -y libpq-dev gcc

# Copy requirements
COPY requirements.txt /code/
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy project
COPY . /code/

# Make entrypoint executable
RUN chmod +x /code/docker-entrypoint.sh

ENTRYPOINT ["/code/docker-entrypoint.sh"]
