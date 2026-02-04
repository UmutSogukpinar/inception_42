FROM debian:bookworm-slim

# Expose port
EXPOSE 443

# Install nginx, openssl and curl
RUN apt-get update && \
    apt-get install -y --fix-missing --no-install-recommends \
    nginx \
    openssl \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration and entrypoint
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/installer.sh /usr/local/bin/nginx_installer.sh
RUN chmod +x /usr/local/bin/nginx_installer.sh

# Create necessary directories
RUN mkdir -p /var/run/nginx /etc/nginx/ssl

# Set entrypoint and default CMD
ENTRYPOINT ["/usr/local/bin/nginx_installer.sh"]

CMD ["nginx", "-g", "daemon off;"]

