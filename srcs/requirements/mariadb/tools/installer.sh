#!/bin/sh
set -e

# Load environment variables
DB_USER=${MYSQL_USER}
DB_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
DB_ROOT_PASSWORD=$(cat $MYSQL_ROOT_PASSWORD_FILE)

# Validate required environment variables
[ -z "$DB_USER" ] && echo "DB_USER not set" && exit 1
[ -z "$MYSQL_DATABASE" ] && echo "MYSQL_DATABASE not set" && exit 1
[ ! -f "$MYSQL_PASSWORD_FILE" ] && echo "Password file missing" && exit 1
[ ! -f "$MYSQL_ROOT_PASSWORD_FILE" ] && echo "Root password file missing" && exit 1
[ -z "$DB_ROOT_PASSWORD" ] && echo "DB_ROOT_PASSWORD not set" && exit 1
[ -z "$DB_PASSWORD" ] && echo "DB_PASSWORD not set" && exit 1

# Initialize MariaDB data directory if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB service for initial setup
mysqld --user=mysql &

# Wait for MariaDB to be ready
until mysqladmin ping >/dev/null 2>&1; do
    echo "Waiting for MariaDB to be ready..."
    sleep 2
done

echo "MariaDB is ready for configuration"

# Create database and user
mysql --user=root <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${DB_USER}'@'%';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

# Stop the temporary MariaDB instance
mysqladmin -uroot -p"${DB_ROOT_PASSWORD}" shutdown

echo "MariaDB configured successfully"

# Start MariaDB in the foreground
exec mysqld --user=mysql