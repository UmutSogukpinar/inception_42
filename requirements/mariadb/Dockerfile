FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*

COPY conf/mariadb.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

CMD ["mysqld_safe"]
