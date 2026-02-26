#!/bin/bash

set -e

SSL_DIR="${SSL_DIR:-/etc/nginx/ssl}"
SSL_KEY="${SSL_KEY:-$SSL_DIR/nginx.key}"
SSL_CRT="${SSL_CRT:-$SSL_DIR/nginx.crt}"

mkdir -p "$SSL_DIR"

if [ ! -f "$SSL_KEY" ] || [ ! -f "$SSL_CRT" ]; then
    echo "[INFO] Generating SSL certificate..."

    : "${DOMAIN_NAME:?DOMAIN_NAME variable not set}"

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SSL_KEY" \
        -out "$SSL_CRT" \
        -subj "/C=TR/ST=ISTANBUL/L=SARIYER/O=42ISTANBUL/CN=$DOMAIN_NAME"

    echo "[INFO] SSL certificate generated successfully."
else
    echo "[INFO] SSL certificate already exists."
fi

exec "$@"
