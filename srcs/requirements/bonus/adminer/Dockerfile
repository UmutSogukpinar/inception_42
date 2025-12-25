FROM alpine:3.19

RUN apk add --no-cache \
    php82 \
    php82-cli \
    php82-curl \
    php82-mysqli \
    php82-json \
    php82-xml \
    php82-openssl \
    wget \
    curl \
    ca-certificates \
    && update-ca-certificates

WORKDIR /var/www/html

RUN wget -O index.php \
    https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
