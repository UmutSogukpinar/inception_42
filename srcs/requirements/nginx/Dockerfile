# Base image
FROM debian:bullseye

# Expose HTTPS port
EXPOSE 443

# Install NGINX and OpenSSL
# then create necessary directories
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    mkdir -p /etc/nginx/ssl /run/nginx

# Copy custom NGINX configuration and installer script into the container
COPY ./conf/nginx.conf /etc/nginx/sites-enabled/default

COPY ./tools/installer.sh /var/www/nginxInstaller.sh

# Make the installer script executable
RUN chmod +x /var/www/nginxInstaller.sh

# Start NGINX and run installer at container start, not build time
CMD ["/bin/sh", "-c", "/var/www/nginxInstaller.sh && exec nginx -g 'daemon off;'"]
