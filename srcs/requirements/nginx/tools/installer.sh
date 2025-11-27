#!/bin/bash

# Generate SSL certificate if it doesn't exist
if [ ! -f "/etc/nginx/ssl/nginx.key" ] || [ ! -f "/etc/nginx/ssl/nginx.crt" ]; then
    echo "Generating SSL certificate..."

    if [ -z "$DOMAIN_NAME" ]; then
        echo "DOMAIN_NAME variable does not exist. Using localhost..."
        DOMAIN_NAME="localhost"
    fi

    openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
        -keyout /etc/nginx/ssl/nginx.key                \
        -out /etc/nginx/ssl/nginx.crt                   \
        -subj "/C=TR/ST=ISTANBUL/L=SARIYER/O=42ISTANBUL/CN=$DOMAIN_NAME"
    
    echo "SSL certificate generated successfully"
else
    echo "SSL certificate already exists"
fi

# Wait a moment for Nginx to start accepting connections
sleep 2

exec "$@"