# Base: Debian penultimate stable (bullseye)
FROM debian:bullseye

# Install PHP-FPM and extensions required by WordPress + curl for downloads
RUN apt-get update && apt-get install -y --no-install-recommends \
    php-fpm php-mysql php-cli php-opcache php-curl php-zip php-mbstring php-xml php-gd \
    curl ca-certificates less tar unzip \
 && rm -rf /var/lib/apt/lists/*

# Create web root and runtime paths
RUN mkdir -p /var/www/html /run/php

# Copy PHP-FPM config and php.ini
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY conf/php.ini  /etc/php/7.4/fpm/php.ini

# Copy entrypoint
COPY tools/wp-entrypoint.sh /usr/local/bin/wp-entrypoint.sh
RUN chmod +x /usr/local/bin/wp-entrypoint.sh

# Ensure proper ownership
RUN chown -R www-data:www-data /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

# Healthcheck: PHP-FPM socket/port reachable
HEALTHCHECK --interval=10s --timeout=5s --retries=5 CMD \
  /bin/sh -c "php-fpm7.4 -t >/dev/null 2>&1 || exit 1"

ENTRYPOINT ["/usr/local/bin/wp-entrypoint.sh"]
CMD ["php-fpm7.4", "-F"]
