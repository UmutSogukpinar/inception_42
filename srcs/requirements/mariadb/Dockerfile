FROM debian:bookworm-slim

# Install MariaDB server and client
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    mariadb-client \
    mariadb-server \
    && mkdir -p /var/log/mysql /run/mysqld /var/lib/mysql \
    && chown -R mysql:mysql /var/log/mysql /run/mysqld /var/lib/mysql \
    && rm -rf /var/lib/apt/lists/*

# ===== Copy config files =====

COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d/

COPY ./tools/installer.sh /usr/local/bin/mariadb_installer.sh

# Make the installer script executable
RUN chmod +x /usr/local/bin/mariadb_installer.sh

# Expose port
EXPOSE 3306

# ===== Set entrypoint =====
ENTRYPOINT ["/usr/local/bin/mariadb_installer.sh"]
