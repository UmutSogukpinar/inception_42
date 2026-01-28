FROM alpine:3.18

# Install Redis and create necessary directories with proper permissions
RUN apk add --no-cache redis \
 && mkdir -p /etc/redis /var/run/redis \
 && chown -R redis:redis /var/run/redis /etc/redis \
 && chmod 777 /var/run/redis

# Copy custom Redis configuration file
COPY conf/redis.conf /etc/redis/redis.conf

# Copy initialization script and make it executable
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Expose Redis default port
EXPOSE 6379

# Run initialization script on container start
ENTRYPOINT ["/usr/local/bin/init.sh"]
