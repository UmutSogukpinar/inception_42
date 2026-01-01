#!/bin/bash

set -e

# ===== Check for existing SSL certificates =====

if [ ! -f "/etc/nginx/ssl/nginx.key" ] || [ ! -f "/etc/nginx/ssl/nginx.crt" ]; then
    echo "[INFO] Generating SSL certificate..."

    # Use localhost if DOMAIN_NAME environment variable is not set
    if [ -z "$DOMAIN_NAME" ]; then
        echo "[WARNING] DOMAIN_NAME variable not set. Defaulting to localhost."
        DOMAIN_NAME="localhost"
    fi

    # Generate self-signed SSL certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=TR/ST=ISTANBUL/L=SARIYER/O=42ISTANBUL/CN=$DOMAIN_NAME"

    echo "[INFO] SSL certificate generated successfully."
else
    echo "[INFO] SSL certificate already exists."
fi

# Execute the command passed as argument
# "nginx" "-g" "daemon off" ;
exec "$@"
