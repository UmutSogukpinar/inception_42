FROM debian:bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y	\
        bash 								\
        curl 								\
        wget 								\
        php 								\
        php-cli 							\
        php-cgi 							\
        php-fpm 							\
        php-mysql 							\
        php-pdo 							\
        php-gd 								\
        php-mbstring 						\
    && rm -rf /var/lib/apt/lists/*

# Install wordpress-client
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar &&	\
    chmod +x wp-cli.phar && 																\
    mv wp-cli.phar /usr/local/bin/wp

# Ensure runtime folder exists
RUN mkdir -p /run/php

# Copy custom PHP-FPM config
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Copy WordPress setup script
COPY ./tools/installer.sh /usr/local/bin/wordpressInstaller.sh

# Make the script executable
RUN chmod +x /usr/local/bin/wordpressInstaller.sh

# Set the entrypoint to the WordPress setup script
ENTRYPOINT ["/usr/local/bin/wordpressInstaller.sh"]

# Set working directory
WORKDIR /var/www/html/

# Expose port 9000 and start PHP-FPM server
EXPOSE 9000

# Keep the container running by starting PHP-FPM in the foreground
CMD ["/usr/sbin/php-fpm7.4", "-F"]