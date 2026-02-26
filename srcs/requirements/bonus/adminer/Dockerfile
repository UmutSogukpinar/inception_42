FROM alpine:3.22

ARG ADMINER_VERSION=5.4.1

# ===== Install Dependencies =====

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
    ca-certificates


# ===== Download Adminer =====

RUN mkdir -p /var/www/html && \
    curl -fL "https://github.com/vrana/adminer/releases/download/v${ADMINER_VERSION}/adminer-${ADMINER_VERSION}.php" \
    -o /var/www/html/index.php

RUN adduser -D -u 1000 adminer && \
    chown -R adminer:adminer /var/www/html

USER adminer

#  ============= Start Adminer =============

ENTRYPOINT ["php"]
CMD ["-S", "0.0.0.0:8080", "-t", "/var/www/html"]
