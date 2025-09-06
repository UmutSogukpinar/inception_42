#!/bin/bash

if [ -f "/root/certs/nginx-selfsigned.key" ] && [ -f "/root/certs/nginx-selfsigned.crt" ]; then
    echo "Certificate is already created."
else
    echo "Generating a certificate..."

    if [ -z "$DOMAIN_NAME" ]; then
        echo "DOMAIN_NAME variable does not exist. Exiting..."
        exit 1
    fi

    openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
        -keyout /etc/nginx/ssl/nginx.key                \
        -out /etc/nginx/ssl/nginx.crt                   \
        -subj "/C=TR/ST=ISTANBUL/L=SARIYER/O=42ISTANBUL/CN=$DOMAIN_NAME"

fi

exec "$@"
