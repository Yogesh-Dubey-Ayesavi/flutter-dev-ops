# # Stage 1
# FROM debian:latest AS build-env

# ARG SSH_PRIVATE_KEY
# ARG KNOWN_HOSTS

# # Install dependencies
# RUN apt-get update && \
#     apt-get install -y \
#     curl git wget python3 \
#     zip unzip apt-transport-https \
#     ca-certificates gnupg clang \
#     cmake ninja-build pkg-config \
#     libgconf-2-4 gdb libstdc++6 \
#     libglu1-mesa fonts-droid-fallback \
#     libgtk-3-dev
    
# RUN apt-get install git -y    

# RUN apt-get install openssh-server -y

# # SSH key setup
# RUN mkdir -p /root/.ssh && \
#     echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_ed25519 && \
#     echo "$KNOWN_HOSTS" > /root/.ssh/known_hosts && \
#     chmod -R 600 /root/.ssh/

# # Clean up
# RUN apt-get clean

# # Clone Flutter
# RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# # Set Flutter environment variables
# ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# # Run Flutter doctor for diagnostics
# RUN flutter doctor -v

# # Set Flutter channel, upgrade, and enable web
# RUN flutter channel master
# RUN flutter upgrade
# RUN flutter config --enable-web

# # Create a directory for the app and copy the source code
# RUN mkdir /app/
# COPY . /app/
# WORKDIR /app/

# # Build the Flutter web app
# RUN flutter build web

# # Stage 2 
# FROM nginx:1.21.1-alpine

# # Copy the built Flutter web app from the build stage
# COPY --from=build-env /app/build/web /usr/share/nginx/html

# # If you have a custom NGINX configuration file, you can uncomment the line below and copy it
# # COPY nginx.conf /etc/nginx/conf.d/default.conf
FROM ubuntu:latest

ARG SSH_PRIVATE_KEY
ARG KNOWN_HOSTS


# Update package lists and install necessary packages
RUN apt-get update && \
    apt-get install -y git openssh-client && \
    rm -rf /var/lib/apt/lists/*

# Set up SSH key
RUN mkdir -p /root/.ssh && \
    echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_ed25519 && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/id_ed25519 && \
    touch /root/.ssh/known_hosts && \
    chmod 644 /root/.ssh/known_hosts && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts

# Clone the repository
RUN git clone git@github.com:nomanmurtaza786/ed_ui_widget.git
