#!/bin/sh
set -e

# ======================= Load variables =======================

DB_USER="${MYSQL_USER}"
DB_NAME="${MYSQL_DATABASE}"
DB_PASSWORD="$(cat "$MYSQL_PASSWORD_FILE")"
DB_ROOT_PASSWORD="$(cat "$MYSQL_ROOT_PASSWORD_FILE")"

SOCKET="/run/mysqld/mysqld.sock"
DATADIR="/var/lib/mysql"

echo "[INFO] MariaDB entrypoint starting..."

# ======================= Validation =======================

[ -z "$DB_USER" ] && echo "[ERROR] MYSQL_USER not set" && exit 1
[ -z "$DB_NAME" ] && echo "[ERROR] MYSQL_DATABASE not set" && exit 1
[ -z "$DB_PASSWORD" ] && echo "[ERROR] MYSQL_PASSWORD is empty" && exit 1
[ -z "$DB_ROOT_PASSWORD" ] && echo "[ERROR] MYSQL_ROOT_PASSWORD is empty" && exit 1

# ======================= Initialize DB =======================

if [ ! -d "$DATADIR/mysql" ]; then
    echo "[INFO] Database directory empty. Initializing..."
    mysqld --initialize-insecure
    echo "[SUCCESS] Database initialized."
else
    echo "[INFO] Existing database detected. Skipping initialization."
fi

# ======================= Temporary server =======================

echo "[INFO] Starting temporary MariaDB (socket only)..."
mysqld --skip-networking &
PID=$!

echo "[INFO] Waiting for MariaDB to be ready..."

until mysqladmin ping --silent; do
    echo "[WAIT] MariaDB not ready yet..."
    sleep 1
done

echo "[SUCCESS] MariaDB is ready."

# ======================= SQL setup =======================

echo "[INFO] Configuring database and users..."

mysql -u root -p"${DB_ROOT_PASSWORD}" <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

FLUSH PRIVILEGES;
EOSQL

echo "[SUCCESS] Database and users configured."

# ======================= Shutdown temp server =======================

echo "[INFO] Shutting down temporary MariaDB..."
mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
wait "$PID"

echo "[SUCCESS] Temporary MariaDB stopped."

# ======================= Start real server =======================

echo "[INFO] Starting MariaDB server..."
exec mysqld
