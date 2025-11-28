FROM debian:bullseye

# Update system and install Redis
RUN apt-get update -y && \
    apt-get install -y redis-server && \
    rm -rf /var/lib/apt/lists/*

# Copy custom redis config
COPY conf/redis.conf /etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf"]
