FROM debian:bullseye

# Install Redis Server
RUN apt-get update && \
    apt-get install -y --no-install-recommends redis-server && \
    rm -rf /var/lib/apt/lists/*

# 2. Copy the custom configuration file
COPY conf/redis.conf /etc/redis/redis.conf

# Copy the initialization script and make it executable
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Set permissions for the data directory
RUN mkdir -p /var/run/redis && \
    chown -R redis:redis /var/run/redis && \
    chmod 777 /var/run/redis

# Expose the Redis port
EXPOSE 6379

ENTRYPOINT ["/usr/local/bin/init.sh"]