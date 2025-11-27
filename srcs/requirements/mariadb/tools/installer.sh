#!/bin/sh
set -e

# ======================= Load environment variables =======================

DB_USER=${MYSQL_USER}
DB_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
DB_ROOT_PASSWORD=$(cat $MYSQL_ROOT_PASSWORD_FILE)
DB_NAME=${MYSQL_DATABASE}


#! Debug (to be removed)
echo "[INFO] Environment Variables Loaded:"
echo "       ➤ DB_USER: $DB_USER"
echo "       ➤ DB_NAME: $DB_NAME"
echo "       ➤ DB_PASSWORD: $DB_PASSWORD"
echo "       ➤ DB_ROOT_PASSWORD: $DB_ROOT_PASSWORD"
echo "       ➤ MYSQL_PASSWORD_FILE: $MYSQL_PASSWORD_FILE"
echo "       ➤ MYSQL_ROOT_PASSWORD_FILE: $MYSQL_ROOT_PASSWORD_FILE"

# ======================= Variable validation =======================================

[ -z "$DB_USER" ] && echo "[ERROR] DB_USER not set" && exit 1
[ -z "$DB_NAME" ] && echo "[ERROR] DB_NAME not set" && exit 1
[ ! -f "$MYSQL_PASSWORD_FILE" ] && echo "[ERROR] Password file not found: $MYSQL_PASSWORD_FILE" && exit 1
[ ! -f "$MYSQL_ROOT_PASSWORD_FILE" ] && echo "[ERROR] Root password file not found: $MYSQL_ROOT_PASSWORD_FILE" && exit 1
[ -z "$DB_ROOT_PASSWORD" ] && echo "[ERROR] DB_ROOT_PASSWORD not set" && exit 1
[ -z "$DB_PASSWORD" ] && echo "[ERROR] DB_PASSWORD not set" && exit 1

# ======================= Initialize Database Directory =======================

SENTINEL_FILE="/var/lib/mysql/.db_init_complete"
IS_FRESH_INSTALL=0

# Check if the sentinel file is missing
if [ ! -f "$SENTINEL_FILE" ]; then
    
    echo "[INFO] Initialization marker not found. Starting fresh installation..."
    IS_FRESH_INSTALL=1
    
    if [ -d "/var/lib/mysql/mysql" ]; then
        echo "[WARN] Partial or corrupt installation detected (mysql dir exists but no marker). Cleaning up..."
        rm -rf /var/lib/mysql/*
    fi

    echo "[INFO] Running mysql_install_db..."

    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db > /tmp/install_db.log 2>&1
    
    INSTALL_EXIT_CODE=$?
    
    if [ $INSTALL_EXIT_CODE -eq 0 ] && [ -f "/var/lib/mysql/mysql/user.frm" ]; then
        
        echo "[SUCCESS] mysql_install_db finished successfully."
        
        touch "$SENTINEL_FILE"
        echo "[INFO] Sentinel file created at $SENTINEL_FILE"
        
    else
        echo "[ERROR] mysql_install_db failed or critical files are missing!"
        echo "[ERROR] Detailed Log:"
        echo "---------------------------------------------------"
        cat /tmp/install_db.log
        echo "---------------------------------------------------"

        exit 1
    fi

else
    echo "[INFO] Verified database installation found. Skipping initialization."
fi

# ======================= Start Temporary MariaDB =======================

echo "[INFO] Starting temporary MariaDB server..."

mysqld --user=mysql --socket=/var/run/mysqld/mysqld.sock --skip-networking &
PID=$!
sleep 5

echo "[INFO] Waiting for MariaDB..."
until mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; do
    echo "[WAIT] Waiting for MariaDB..."
    sleep 2
done

# ======================= Database and User Configuration =======================

echo "[INFO] Configuring Database and Users..."

if [ "$IS_FRESH_INSTALL" -eq 1 ]; then
    echo "[INFO] Fresh installation detected: No root password set, connecting without password..."
    MYSQL_CMD="mysql --socket=/var/run/mysqld/mysqld.sock -u root"
else
    echo "[INFO] Existing installation: Connecting with root password..."
    MYSQL_CMD="mysql --socket=/var/run/mysqld/mysqld.sock -u root -p${DB_ROOT_PASSWORD}"
fi

$MYSQL_CMD <<EOSQL 2>&1 | tee /tmp/sql_setup.log

-- Create root user accessible from everywhere (%) and set password
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
ALTER USER 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Update localhost root password as well (required for socket connections)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

-- Create the application database
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

-- Create the application user
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
ALTER USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}'; -- Updates password if it changed
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

FLUSH PRIVILEGES;
EOSQL

SQL_EXIT_CODE=$?

# ======================= Error Check =======================

if [ $SQL_EXIT_CODE -ne 0 ]; then
    echo "[ERROR] SQL configuration failed!"
    echo "------- LOG START -------"
    cat /tmp/sql_setup.log
    echo "------- LOG END -------"
    
    kill $PID
    exit 1
else
    echo "[SUCCESS] Database configuration completed."
fi

# ======================= Stop Temporary Server =======================

echo "[INFO] Shutting down temporary MariaDB..."

mysqladmin --socket=/var/run/mysqld/mysqld.sock -u root -p"${DB_ROOT_PASSWORD}" shutdown

# ======================= Start Real MariaDB Server =======================

echo "[INFO] Starting Real MariaDB Server..."

exec mysqld --user=mysql --socket=/var/run/mysqld/mysqld.sock