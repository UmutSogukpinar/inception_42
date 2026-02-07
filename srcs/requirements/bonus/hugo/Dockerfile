FROM alpine:3.22

# Install Hugo and required system utilities
RUN apk update && apk add --no-cache \
    hugo \
    git \
    shadow \
    bash

# Copy Hugo initialization script into the container
COPY init.sh /hugo_setup.sh

# Ensure the initialization script is executable
RUN chmod +x /hugo_setup.sh

# Set the working directory
WORKDIR /var/hugo

EXPOSE 1313

# Run the Hugo setup script 
ENTRYPOINT ["/hugo_setup.sh"]
