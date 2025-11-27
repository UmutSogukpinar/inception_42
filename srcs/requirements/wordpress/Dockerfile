FROM debian:bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y --fix-missing --no-install-recommends \
    bash \
    curl \
    wget \
    ca-certificates \
    mariadb-client \
    php7.4 \
    php7.4-cli \
    php7.4-cgi \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-pdo \
    php7.4-xml \
    php7.4-curl \
 && rm -rf /var/lib/apt/lists/*

# Install WordPress CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp


# Set working directory
WORKDIR /var/www/html

# Download WordPress core
RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && rm latest.tar.gz && \
    mv wordpress/* . && rm -rf wordpress

# Copy PHP-FPM configuration
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Create symlink for php-fpm
RUN ln -s /usr/sbin/php-fpm7.4 /usr/sbin/php-fpm

# Copy and prepare installer script
COPY ./tools/installer.sh /usr/local/bin/wordpressInstaller.sh

RUN chmod +x /usr/local/bin/wordpressInstaller.sh

# Expose port
EXPOSE 9000

# Set entrypoint (installer will run php-fpm)
ENTRYPOINT ["/usr/local/bin/wordpressInstaller.sh"]
