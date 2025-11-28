FROM debian:bullseye

# Install PHP and tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    php7.4 \
    php7.4-cli \
    php7.4-curl \
    php7.4-mysql \
    php7.4-json \
    php7.4-xml \
    wget \
    curl \
    ca-certificates \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Download Adminer
RUN wget -O index.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
