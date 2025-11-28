#!/bin/sh
set -e

# ================== Load Environment Variables ==================

echo "[INFO] Loading secrets and environment variables..."

DB_HOST=${WORDPRESS_DB_HOST}
DB_NAME=${WORDPRESS_DB_NAME}
DB_USER=${WORDPRESS_DB_USER}

# Load Database Password
if [ -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
    DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
else
    echo "[ERROR] Database password secret not found!"
    exit 1
fi

# Load Redis Password (CRITICAL FOR BONUS)
# Docker Compose should map the secret to /run/secrets/redis_password
REDIS_SECRET_FILE="/run/secrets/redis_password"

if [ -f "$REDIS_SECRET_FILE" ]; then
    REDIS_PASSWORD=$(cat "$REDIS_SECRET_FILE")
else
    echo "[ERROR] Redis password secret not found at $REDIS_SECRET_FILE"
    echo "       Make sure you added 'secrets: - redis_password' to wordpress service in docker-compose.yml"
    exit 1
fi

# Load WP Admin Credentials
if [ -f "$WP_CREDENTIALS_FILE" ]; then
    WP_ADMIN_USER=$(sed -n '1p' "$WP_CREDENTIALS_FILE" | tr -d '\r\n')
    WP_ADMIN_EMAIL=$(sed -n '2p' "$WP_CREDENTIALS_FILE" | tr -d '\r\n')
    WP_ADMIN_PASSWORD=$(sed -n '3p' "$WP_CREDENTIALS_FILE" | tr -d '\r\n')
else
    echo "[ERROR] Credentials file not found!"
    exit 1
fi

# ================== Validate Required Values ====================

[ -z "$DB_HOST" ] && echo "[ERROR] DB_HOST not set" && exit 1
[ -z "$DB_NAME" ] && echo "[ERROR] DB_NAME not set" && exit 1
[ -z "$DB_USER" ] && echo "[ERROR] DB_USER not set" && exit 1
[ -z "$DB_PASSWORD" ] && echo "[ERROR] DB_PASSWORD empty" && exit 1
[ -z "$REDIS_PASSWORD" ] && echo "[ERROR] REDIS_PASSWORD empty" && exit 1

echo "[INFO] All variables loaded successfully."
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
    echo "[INFO] wp-config.php already exists."
fi

# ========== Configure Redis Settings ==========

echo "[INFO] Configuring Redis in wp-config.php..."

# Set Host (Container name)
wp config set WP_REDIS_HOST 'redis' --allow-root --type=constant

# Set Port
wp config set WP_REDIS_PORT 6379 --raw --allow-root --type=constant

# Set Password (REQUIRED)
wp config set WP_REDIS_PASSWORD "$REDIS_PASSWORD" --allow-root --type=constant

# Enable Cache
wp config set WP_CACHE true --raw --allow-root --type=constant

# Set Database Index
wp config set WP_REDIS_DATABASE 0 --raw --allow-root --type=constant


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

# ================== Redis Plugin Setup ==================

echo "[INFO] Checking Redis plugin status..."
if ! wp plugin is-installed redis-cache --path='/var/www/html' --allow-root; then
    echo "[INFO] Installing Redis plugin..."
    wp plugin install redis-cache --activate --path='/var/www/html' --allow-root
else
    echo "[INFO] Redis plugin is installed. Ensuring activation..."
    wp plugin activate redis-cache --path='/var/www/html' --allow-root
fi

echo "[INFO] Enabling Redis object cache..."
wp redis enable --path='/var/www/html' --allow-root

# ================== Start Server ==================

echo "[INFO] Resetting permissions before startup..."
chown -R www-data:www-data /var/www/html

echo "[INFO] Starting PHP-FPM..."
exec php-fpm -F