FROM debian:bullseye

# Install MariaDB server and client
RUN apt-get update &&                                   \
    apt-get install -y mariadb-client mariadb-server && \
    apt-get clean &&                                    \
    rm -rf /var/lib/apt/lists/*

EXPOSE 3306

COPY ./conf/mariadb.cnf /etc/mysql/mariadb.conf.d/

COPY ./tools/installer.sh /mariadbInstaller.sh

RUN chmod +x /mariadbInstaller.sh

ENTRYPOINT ["/mariadbInstaller.sh"]