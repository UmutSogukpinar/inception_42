#!/bin/sh

set -e

# Generate SSL certificate if it does not exist
if [ ! -f /etc/nginx/ssl/server.crt ] || [ ! -f /etc/nginx/ssl/server.key ]; then
    openssl req -x509 -nodes -newkey rsa:2048 -days 365         \
        -subj "/CN=localhost"                                   \
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"     \
        -keyout /etc/nginx/ssl/server.key                       \
        -out /etc/nginx/ssl/server.crt
    chmod 600 /etc/nginx/ssl/server.key
fi

# Create runtime directory for Nginx
mkdir -p /run/nginx

# Check configuration syntax
nginx -t

# Start Nginx in foreground
exec "$@"
