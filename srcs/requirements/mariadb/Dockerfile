FROM debian:bookworm-slim

# =============== Install Dependencies ===============

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    mariadb-client \
    mariadb-server \
    && mkdir -p /var/log/mysql /run/mysqld /var/lib/mysql \
    && chown -R mysql:mysql /var/log/mysql /run/mysqld /var/lib/mysql \
    && rm -rf /var/lib/apt/lists/*

# =============== Execute Configurations ===============

COPY ./conf/mariadb.cnf /etc/mysql/mariadb.conf.d/

COPY ./tools/installer.sh /usr/local/bin/mariadb_installer.sh

RUN chmod +x /usr/local/bin/mariadb_installer.sh

ENTRYPOINT ["/usr/local/bin/mariadb_installer.sh"]
