# Start from base image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy dependencies first (to leverage Docker cache)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Add a non-root user
RUN useradd -m flaskuser

# Copy the app code
COPY app/ .

# Switch to non-root user
USER flaskuser

# Expose port
EXPOSE 5000

# Start the app
CMD ["python", "app.py"]
