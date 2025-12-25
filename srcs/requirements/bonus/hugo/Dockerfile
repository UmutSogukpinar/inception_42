FROM alpine:3.19

# Install Hugo and required tools
RUN apk add --no-cache \
    hugo \
    git \
    ca-certificates \
    && update-ca-certificates

# Arrange working directory
WORKDIR /opt/site

# Copy the Hugo initialization script
COPY init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/init.sh"]
