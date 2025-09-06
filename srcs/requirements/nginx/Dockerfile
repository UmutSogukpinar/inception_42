# Base image
FROM debian:bullseye

# Install NGINX and OpenSSL
# then create necessary directories
RUN apt-get update &&                   \ 
    apt-get install -y nginx openssl && \
    mkdir -p /etc/nginx/ssl /run/nginx

# Copy custom NGINX configuration and installer script into the container
COPY ./conf/nginx.conf /etc/nginx/sites-enabled/default

COPY ./tools/installer.sh /var/www/nginxInstaller.sh

# Make the installer script executable
RUN chmod +x /var/www/nginxInstaller.sh

# Expose HTTPS port
EXPOSE 443

# Run the installer script as entrypoint
ENTRYPOINT ["/var/www/nginxInstaller.sh"]

# Start NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]
