# Dockerfile for Django Portfolio
# Optional: Use this for containerized deployment

FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt /app/
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy project
COPY . /app/

# Create necessary directories
RUN mkdir -p /app/logs /app/staticfiles

# Collect static files
RUN python manage.py collectstatic --noinput --settings=portfolio.settings_production || true

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000')" || exit 1

EXPOSE 8000

CMD ["gunicorn", "--config", "gunicorn_config.py", "--workers", "4", "--bind", "0.0.0.0:8000", "portfolio.wsgi:application"]
