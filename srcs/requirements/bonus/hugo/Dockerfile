FROM debian:bullseye

# Install Hugo and necessary dependencies
RUN apt-get update && \
    apt-get install -y hugo git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Arrange working directory
WORKDIR /opt/site

# Copy the Hugo initialization script into the container
COPY hugo_init.sh /usr/local/bin/hugo_init.sh
RUN chmod +x /usr/local/bin/hugo_init.sh

# Set the entrypoint to the Hugo initialization script
ENTRYPOINT ["/usr/local/bin/hugo_init.sh"]