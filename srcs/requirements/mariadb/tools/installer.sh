#!/bin/sh
set -e

# ======================= Load variables =======================

DB_USER="${MYSQL_USER}"
DB_NAME="${MYSQL_DATABASE}"

DB_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
DB_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")

DATADIR="/var/lib/mysql"

echo "[INFO] MariaDB entrypoint starting..."

# ======================= Validation =======================

[ -z "$DB_USER" ] && echo "[ERROR] MYSQL_USER not set" && exit 1
[ -z "$DB_NAME" ] && echo "[ERROR] MYSQL_DATABASE not set" && exit 1
[ -z "$DB_PASSWORD" ] && echo "[ERROR] MYSQL_PASSWORD is empty" && exit 1
[ -z "$DB_ROOT_PASSWORD" ] && echo "[ERROR] MYSQL_ROOT_PASSWORD is empty" && exit 1

# ======================= Initialize DB =======================

MYSQLD_ARGS="--console --datadir=${DATADIR} --user=mysql"

if [ ! -d "$DATADIR/mysql" ]; then
    echo "[INFO] Database directory empty. Initializing..."

    mysqld --initialize-insecure > /dev/null 2>&1
    echo "[SUCCESS] Database initialized."
    echo "[INFO] Configuring database and users..."

    cat << EOF > /tmp/init.sql

ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

FLUSH PRIVILEGES;

EOF

    MYSQLD_ARGS="$MYSQLD_ARGS --init-file=/tmp/init.sql"

    echo "[SUCCESS] Configuration file created."

else
    echo "[INFO] Existing database detected. Skipping initialization."
fi

# ======================= Start server =======================

echo "[INFO] Cleaning up environment variables..."
unset MYSQL_USER MYSQL_DATABASE MYSQL_PASSWORD_FILE MYSQL_ROOT_PASSWORD_FILE DB_PASSWORD DB_ROOT_PASSWORD

echo "[INFO] Starting MariaDB server..."
exec mysqld $MYSQLD_ARGS
