```dockerfile
# Use the official Python image as a base
FROM python:3.10-slim

# Set environment variables for Python
ENV PYTHONUNBUFFERED 1 \
    PYTHONDONTWRITEBYTECODE 1

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file and install dependencies
# This leverages Docker's layer caching. If requirements.txt doesn't change,
# this layer won't be rebuilt.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire application code into the container
COPY . .

# Create a non-root user and set permissions for security best practices
# The 'appuser' will run the application
RUN addgroup --system appgroup && adduser --system --group appgroup appuser
RUN chown -R appuser:appgroup /app
USER appuser

# Expose the port the app runs on
EXPOSE 5000

# Command to run the application using Gunicorn
# It binds to 0.0.0.0 to be accessible from outside the container
# --workers: Number of worker processes (a common rule is 2 * CPU_COUNT + 1)
# --threads: Number of threads per worker (useful for I/O bound apps)
# app:app assumes your Flask application instance is named 'app'
# and is located in a file named 'app.py' at the root of your application.
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--threads", "2", "app:app"]
```