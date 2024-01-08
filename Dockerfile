# Stage 1
FROM debian:latest AS build-env

ARG SSH_PRIVATE_KEY
ARG KNOWN_HOSTS

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl git wget python3 \
    zip unzip apt-transport-https \
    ca-certificates gnupg clang \
    cmake ninja-build pkg-config \
    libgconf-2-4 gdb libstdc++6 \
    libglu1-mesa fonts-droid-fallback \
    libgtk-3-dev

# SSH key setup
RUN mkdir -p /root/.ssh && \
    echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_ed25519 && \
    echo "$KNOWN_HOSTS" > /root/.ssh/known_hosts && \
    chmod -R 600 /root/.ssh/

# Clean up
RUN apt-get clean

# Clone Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set Flutter environment variables
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run Flutter doctor for diagnostics
RUN flutter doctor -v

# Set Flutter channel, upgrade, and enable web
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

# Create a directory for the app and copy the source code
RUN mkdir /app/
COPY . /app/
WORKDIR /app/

# Build the Flutter web app
RUN flutter build web

# Stage 2 
FROM nginx:1.21.1-alpine

# Copy the built Flutter web app from the build stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

# If you have a custom NGINX configuration file, you can uncomment the line below and copy it
# COPY nginx.conf /etc/nginx/conf.d/default.conf
