#!/bin/sh
set -e

# ================== Load Environment Variables ==================

DB_HOST=${WORDPRESS_DB_HOST}
DB_NAME=${WORDPRESS_DB_NAME}
DB_USER=${WORDPRESS_DB_USER}
DB_PASSWORD=$(cat $WORDPRESS_DB_PASSWORD_FILE)

WP_ADMIN_USER=$(sed -n '1p' "$WP_CREDENTIALS_FILE" | tr -d '\r\n')
WP_ADMIN_EMAIL=$(sed -n '2p' "$WP_CREDENTIALS_FILE" | tr -d '\r\n')
WP_ADMIN_PASSWORD=$(sed -n '3p' "$WP_CREDENTIALS_FILE" | tr -d '\r\n')

#! Debug (to be removed)
echo "[INFO] Environment Variables Loaded:"
echo "       ➤ DOMAIN_NAME: $DOMAIN_NAME"
echo "       ➤ DB_HOST: $DB_HOST"
echo "       ➤ DB_NAME: $DB_NAME"
echo "       ➤ DB_USER: $DB_USER"
echo "       ➤ DB_PASSWORD: $DB_PASSWORD"
echo "       ➤ WP_ADMIN_USER: $WP_ADMIN_USER"
echo "       ➤ WP_ADMIN_EMAIL: $WP_ADMIN_EMAIL"
echo "       ➤ WP_ADMIN_PASSWORD: ********"
echo "       ➤ WORDPRESS_DB_PASSWORD_FILE: $WORDPRESS_DB_PASSWORD_FILE"
echo "       ➤ WP_CREDENTIALS_FILE: $WP_CREDENTIALS_FILE"

# ================== Validate Required Values ====================

[ -z "$DB_HOST" ] && echo "[ERROR] DB_HOST not set" && exit 1
[ -z "$DB_NAME" ] && echo "[ERROR] DB_NAME not set" && exit 1
[ -z "$DB_USER" ] && echo "[ERROR] DB_USER not set" && exit 1
[ -z "$DB_PASSWORD" ] && echo "[ERROR] DB_PASSWORD not set" && exit 1
[ -z "$WP_ADMIN_USER" ] && echo "[ERROR] WP_ADMIN_USER not set" && exit 1
[ -z "$WP_ADMIN_EMAIL" ] && echo "[ERROR] WP_ADMIN_EMAIL not set" && exit 1
[ -z "$WP_ADMIN_PASSWORD" ] && echo "[ERROR] WP_ADMIN_PASSWORD not set" && exit 1

[ ! -f "$WORDPRESS_DB_PASSWORD_FILE" ] && echo "[ERROR] Missing DB password file" && exit 1
[ ! -f "$WP_CREDENTIALS_FILE" ] && echo "[ERROR] Missing credentials file" && exit 1

echo "[INFO] Starting WordPress setup..."

# ========== Runtime & Directory Setup ==========

mkdir -p /run/php
chown -R www-data:www-data /run/php

chown -R www-data:www-data /var/www/html

## ================== Config File Setup ==================

if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "[INFO] wp-config.php not found. Creating..."
    
    wp config create \
      --dbname="$DB_NAME" \
      --dbuser="$DB_USER" \
      --dbpass="$DB_PASSWORD" \
      --dbhost="$DB_HOST" \
      --path='/var/www/html' \
      --skip-check \
      --allow-root
else
    echo "[INFO] wp-config.php already exists. Skipping config creation."
fi

# ========== Wait for MariaDB ==========

echo "[INFO] Waiting for MariaDB connection..."
until wp db check --path='/var/www/html' --allow-root >/dev/null 2>&1; do
    echo "[WAIT] MariaDB is not reachable yet..."
    sleep 3
done
echo "[SUCCESS] Connected to MariaDB."

# ================== WordPress Installation Check ==================

if ! wp core is-installed --path='/var/www/html' --allow-root; then
    echo "[INFO] WordPress tables are missing. Installing..."
    
    wp core install \
      --url="https://${DOMAIN_NAME}:5050" \
      --title="WordPress Inception" \
      --admin_user="$WP_ADMIN_USER" \
      --admin_password="$WP_ADMIN_PASSWORD" \
      --admin_email="$WP_ADMIN_EMAIL" \
      --path='/var/www/html' \
      --skip-email \
      --allow-root

    echo "[INFO] Updating site options..."
    wp option update blogdescription "Just another WordPress site" --path='/var/www/html' --allow-root
    
    echo "[SUCCESS] WordPress installation completed."
else
    echo "[INFO] WordPress is already installed. Skipping installation."
fi

# ================== Start Server ==================

echo "[INFO] Resetting permissions before startup..."
chown -R www-data:www-data /var/www/html

echo "[INFO] Starting PHP-FPM..."
exec php-fpm -F
