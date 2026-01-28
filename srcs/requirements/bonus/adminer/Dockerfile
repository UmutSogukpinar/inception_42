FROM alpine:3.20

# ===== Install PHP and utilities =====

RUN apk add --no-cache \
    php \
    php-cli \
    php-session \
    php-mysqli \
    php-pdo_mysql \
    php-json \
    php-xml \
    php-curl \
    curl \
    wget \
    ca-certificates

# Set working directory
WORKDIR /var/www/html

# ===== Download Adminer =====

# --no-check-certificate added to avoid SSL issues on Alpine
RUN wget --no-check-certificate -O index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php


# Expose Port
EXPOSE 8080

# ===== Start PHP built-in server =====

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
