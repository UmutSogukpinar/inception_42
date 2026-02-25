FROM debian:bookworm-slim

# ====== Install Dependencies ======

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash curl wget ca-certificates \
        mariadb-client \
        netcat-openbsd \
        php8.2 \
        php8.2-cli \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-gd \
        php8.2-mbstring \
        php8.2-xml \
        php8.2-curl \
        php-redis \
    && ln -s /usr/sbin/php-fpm8.2 /usr/sbin/php-fpm \
    && mkdir -p /run/php && chown www-data:www-data /run/php \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html

RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress/* . && \
    rm -rf wordpress latest.tar.gz && \
    chown -R www-data:www-data /var/www/html

# =========== Execute Configurations ===========

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf


COPY ./tools/installer.sh /usr/local/bin/wp_installer.sh
RUN chmod +x /usr/local/bin/wp_installer.sh


ENTRYPOINT ["/usr/local/bin/wp_installer.sh"]
