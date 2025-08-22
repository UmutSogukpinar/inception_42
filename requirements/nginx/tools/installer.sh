#!/bin/sh
set -e

# 1) Sertifikalar yoksa oluştur (SAN içersin — modern tarayıcılar ister)
if [ ! -f /etc/nginx/ssl/server.crt ] || [ ! -f /etc/nginx/ssl/server.key ]; then
  openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -subj "/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt
  chmod 600 /etc/nginx/ssl/server.key
fi

# 2) Nginx runtime dizini
mkdir -p /run/nginx

# 3) Konfig testi
nginx -t

# 4) CMD’yi (nginx -g 'daemon off;') PID 1 olarak başlat
exec "$@"
