FROM debian:bullseye

# Install MariaDB server and client
RUN apt-get update && \
    apt-get install -y mariadb-client mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ===== Setup MariaDB =====
# Create necessary directories and set permissions
RUN mkdir -p /var/log/mysql /run/mysqld && \
    chown -R mysql:mysql /var/log/mysql /run/mysqld /var/lib/mysql

# ===== Copy config files =====

COPY ./conf/mariadb.cnf /etc/mysql/mariadb.conf.d/

COPY ./tools/installer.sh /usr/local/bin/mariadb_install.sh

# Make the installer script executable
RUN chmod +x /usr/local/bin/mariadb_install.sh

# ===== Expose port =====
EXPOSE 3306

# ===== Set entrypoint =====
ENTRYPOINT ["/usr/local/bin/mariadb_install.sh"]