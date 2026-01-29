#!/bin/sh
set -e

# ======================= Load variables =======================

DB_USER="${MYSQL_USER}"
DB_NAME="${MYSQL_DATABASE}"

DB_PASSWORD="$(cat "$MYSQL_PASSWORD_FILE")"
DB_ROOT_PASSWORD="$(cat "$MYSQL_ROOT_PASSWORD_FILE")"

DATADIR="/var/lib/mysql"
MYSQLD_ARGS="--console --datadir=${DATADIR} --user=mysql"

echo "[INFO] MariaDB entrypoint starting..."

# ======================= Validation =======================

[ -z "$DB_USER" ] && echo "[ERROR] MYSQL_USER not set" && exit 1
[ -z "$DB_NAME" ] && echo "[ERROR] MYSQL_DATABASE not set" && exit 1
[ -z "$DB_PASSWORD" ] && echo "[ERROR] MYSQL_PASSWORD is empty" && exit 1
[ -z "$DB_ROOT_PASSWORD" ] && echo "[ERROR] MYSQL_ROOT_PASSWORD is empty" && exit 1

# ======================= Functions =======================

prepare_init_file()
{
	init_file="/tmp/init.sql"

	cat << EOF > "$init_file"
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

	MYSQLD_ARGS="${MYSQLD_ARGS} --init-file=${init_file}"
}

initialize_database()
{
	echo "[INFO] Database directory empty. Initializing..."

	mysqld > /dev/null 2>&1

	echo "[INFO] Configuring database and users..."
	prepare_init_file

	echo "[SUCCESS] Configuration file created."
}

# ======================= Initialize DB =======================

if [ ! -d "$DATADIR/mysql" ]; then
	initialize_database
else
	echo "[INFO] Existing database detected. Skipping initialization."
	prepare_init_file
fi

# ======================= Start server =======================

echo "[INFO] Cleaning up environment variables..."
unset DB_USER DB_NAME DB_PASSWORD DB_ROOT_PASSWORD

echo "[INFO] Starting MariaDB server..."
exec mysqld $MYSQLD_ARGS
