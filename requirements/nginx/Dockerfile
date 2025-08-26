# Base image: Debian penultimate stable
FROM debian:bullseye

# Install only required packages
RUN apt-get update && apt-get install -y \
    nginx openssl curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Create required directories
RUN mkdir -p /etc/nginx/ssl /run/nginx /var/www/html

# Copy configuration and entrypoint
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/installer.sh /usr/local/bin/installer.sh
RUN chmod +x /usr/local/bin/installer.sh

# Simple index page (for quick test, can be removed later)
RUN echo "<h1>NGINX over TLS</h1>" > /var/www/html/index.html

# Expose only HTTPS port (443)
EXPOSE 443

# Run entrypoint (generates certs if missing, tests config, then exec CMD)
ENTRYPOINT ["/usr/local/bin/installer.sh"]
CMD ["nginx", "-g", "daemon off;"]
