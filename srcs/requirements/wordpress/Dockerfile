FROM debian:bookworm-slim

# Install system packages (PHP 8.2)
RUN apt-get update && \
    apt-get install -y --fix-missing --no-install-recommends \
        bash curl wget ca-certificates \
        mariadb-client \
        php8.2 \
        php8.2-cli \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-gd \
        php8.2-mbstring \
        php8.2-xml \
        php8.2-curl \
        php-redis \
    && rm -rf /var/lib/apt/lists/*

# Install WordPress CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Set working directory
WORKDIR /var/www/html

# Download and extract WordPress core
RUN wget https://wordpress.org/wordpress-6.9.tar.gz && \
    tar -xzf wordpress-6.9.tar.gz && rm wordpress-6.9.tar.gz && \
    mv wordpress/* . && rm -rf wordpress

# Copy PHP-FPM configuration
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Create a symlink for php-fpm binary
RUN ln -s /usr/sbin/php-fpm8.2 /usr/sbin/php-fpm

# Copy installer script
COPY ./tools/installer.sh /usr/local/bin/wp_installer.sh
RUN chmod +x /usr/local/bin/wp_installer.sh

# Expose PHP-FPM port and set entrypoint
EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp_installer.sh"]
