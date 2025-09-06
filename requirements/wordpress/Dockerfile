FROM debian:bullseye

RUN apt-get update && apt-get install -y php php-mysql curl wget unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN curl -o latest.tar.gz https://wordpress.org/latest.tar.gz \
    && tar -xvzf latest.tar.gz --strip-components=1 \
    && rm latest.tar.gz

COPY conf/php.conf /etc/php/7.4/fpm/php.ini

CMD ["php", "-S", "0.0.0.0:9000", "-t", "/var/www/html"]
