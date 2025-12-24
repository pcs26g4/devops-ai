<<<<<<< HEAD
```dockerfile
# Use the official Python 3.10 slim image as the base image
FROM python:3.10-slim-buster

# Set environment variables for better logging and pip cache behavior
# PYTHONUNBUFFERED ensures that Python output is sent straight to the terminal without buffering.
# PIP_NO_CACHE_DIR prevents pip from storing its cache, reducing image size.
ENV PYTHONUNBUFFERED 1
ENV PIP_NO_CACHE_DIR 1

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies required for some Python packages (e.g., C extensions)
# and for Gunicorn if it has any specific build dependencies.
# python3-dev provides Python header files needed to compile certain Python packages.
# gcc is a C compiler.
# --no-install-recommends minimizes the number of installed packages.
# After installation, apt caches are cleaned to reduce the final image size.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the working directory
# This step is placed early to leverage Docker's layer caching.
# If requirements.txt doesn't change, this layer (and subsequent pip install)
# can be reused, speeding up builds.
COPY requirements.txt .

# Install Python dependencies
# --no-cache-dir prevents pip from creating a cache, further reducing image size.
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the working directory
COPY . .

# Create a non-root user and switch to it for enhanced security
# This limits the potential impact if the application is compromised.
RUN adduser --system --group appuser
USER appuser

# Expose port 5000, which Flask applications typically use
# This informs Docker that the container listens on the specified network ports at runtime.
EXPOSE 5000

# Command to run the application using Gunicorn, a production-ready WSGI server.
# It listens on all network interfaces (0.0.0.0) on port 5000.
# "app:app" assumes your Flask application instance is named 'app'
# and is defined within a file named 'app.py' (i.e., 'app.py' contains `app = Flask(__name__)`).
# Adjust "app:app" if your Flask app is named differently or in a different file
# (e.g., "wsgi:application" if your entry point is 'wsgi.py' and the app object is 'application').
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```
=======
```dockerfile
# Use the official Python 3.10 slim image as the base image
FROM python:3.10-slim-buster

# Set environment variables for better logging and pip cache behavior
# PYTHONUNBUFFERED ensures that Python output is sent straight to the terminal without buffering.
# PIP_NO_CACHE_DIR prevents pip from storing its cache, reducing image size.
ENV PYTHONUNBUFFERED 1
ENV PIP_NO_CACHE_DIR 1

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies required for some Python packages (e.g., C extensions)
# and for Gunicorn if it has any specific build dependencies.
# python3-dev provides Python header files needed to compile certain Python packages.
# gcc is a C compiler.
# --no-install-recommends minimizes the number of installed packages.
# After installation, apt caches are cleaned to reduce the final image size.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the working directory
# This step is placed early to leverage Docker's layer caching.
# If requirements.txt doesn't change, this layer (and subsequent pip install)
# can be reused, speeding up builds.
COPY requirements.txt .

# Install Python dependencies
# --no-cache-dir prevents pip from creating a cache, further reducing image size.
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the working directory
COPY . .

# Create a non-root user and switch to it for enhanced security
# This limits the potential impact if the application is compromised.
RUN adduser --system --group appuser
USER appuser

# Expose port 5000, which Flask applications typically use
# This informs Docker that the container listens on the specified network ports at runtime.
EXPOSE 5000

# Command to run the application using Gunicorn, a production-ready WSGI server.
# It listens on all network interfaces (0.0.0.0) on port 5000.
# "app:app" assumes your Flask application instance is named 'app'
# and is defined within a file named 'app.py' (i.e., 'app.py' contains `app = Flask(__name__)`).
# Adjust "app:app" if your Flask app is named differently or in a different file
# (e.g., "wsgi:application" if your entry point is 'wsgi.py' and the app object is 'application').
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```
>>>>>>> 915394f6a783e1daa8111e12a6419de7ee3fca4c
