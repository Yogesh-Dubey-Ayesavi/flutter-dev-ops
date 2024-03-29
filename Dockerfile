FROM ubuntu

   
# uncomment the following if you want to ensure latest Dart and root CA bundle
#RUN apt -y update && apt -y upgrade
# Setup 
RUN apt-get update && apt-get install -y unzip xz-utils git openssh-client  openssh-server  curl python3 && apt-get upgrade -y && rm -rf /var/cache/apt
#setup ssh key
#setup ssh key

# add credentials on build
ARG SSH_PRIVATE_KEY




RUN mkdir /root/.ssh/
 
# Create id_rsa from string arg, and set permissions

RUN echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa

# Create known_hosts
RUN touch /root/.ssh/known_hosts

# Add git providers to known_hosts

RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web
RUN flutter doctor -v

# Copy files to container and get dependencies
COPY . /usr/local/bin/app
WORKDIR /usr/local/bin/app
RUN flutter pub get

RUN flutter build web

EXPOSE 8080

# Set the server startup script as executable
RUN ["chmod", "+x", "/usr/local/bin/app/server/server.sh"]

ENTRYPOINT  [ "/usr/local/bin/app/server/server.sh" ]
