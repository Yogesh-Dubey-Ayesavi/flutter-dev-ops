# Use an official Flutter runtime as a parent image
FROM ubuntu:latest

# Set the working directory
WORKDIR /app

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    git \
    openssh-client \
    unzip \
    python3 \
    python3-pip

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"

# Run Flutter precache to download dependencies
RUN flutter precache

# Set up SSH keys using build arguments
ARG SSH_PRIVATE_KEY
ARG KNOWN_HOSTS

# Set up SSH keys
RUN mkdir -p /root/.ssh && \
    echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa && \
    echo "$KNOWN_HOSTS" > /root/.ssh/known_hosts

# Copy the rest of the application code
COPY . .

# Build the Flutter web app
RUN flutter build web

# Install a simple web server (e.g., using Python)
RUN pip3 install http.server

# Expose the port the app runs on (assuming it's 8080 for web)
EXPOSE 8080

# CMD ["flutter", "run"]  # No need to run the app, as we only built the web version

# Run a simple web server to serve the Flutter web app
CMD ["python3", "-m", "http.server", "8080"]
