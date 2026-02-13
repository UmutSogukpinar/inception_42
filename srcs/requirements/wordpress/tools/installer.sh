#!/bin/sh
set -e

# ================== Load Environment Variables ==================

echo "[INFO] Loading secrets and environment variables..."

WP_PATH="/var/www/html"
BLACK_HOLE="/dev/null"

DOMAIN_NAME=${DOMAIN_NAME}

WP_TITLE=${WORDPRESS_TITLE}
WP_ADMIN_USER=$WORDPRESS_ADMIN_USER
WP_ADMIN_EMAIL=$WORDPRESS_ADMIN_EMAIL

DB_HOST=$WORDPRESS_DB_HOST
DB_NAME=$WORDPRESS_DB_NAME
DB_USER=$WORDPRESS_DB_USER

# Load Database Password
if [ -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
    DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
else
    echo "[ERROR] Database password secret file not found!"
    exit 1
fi

# Load Redis Password
REDIS_SECRET_FILE="/run/secrets/redis_password"

if [ -f "$REDIS_SECRET_FILE" ]; then
    REDIS_PASSWORD=$(cat "$REDIS_SECRET_FILE")
else
    echo "[ERROR] Redis password secret not found at $REDIS_SECRET_FILE"
    echo "Make sure you added 'secrets: - redis_password' to wordpress service in docker-compose.yml"
    exit 1
fi

# Load WP Admin Credentials
if [ -f "$WORDPRESS_ADMIN_PASSWORD_FILE" ]; then
    WP_ADMIN_PASSWORD=$(cat "$WORDPRESS_ADMIN_PASSWORD_FILE")
else
    echo "[ERROR] WORDPRESS_ADMIN_PASSWORD_FILE not found!"
    exit 1
fi

# ================== Validate Required Values ====================

[ -z "$DOMAIN_NAME" ] && echo "[ERROR] DOMAIN_NAME not set!" && exit 1

[ -z "$WP_TITLE" ] && echo "[ERROR] WP_TITLE not set!" && exit 1
[ -z "$WP_ADMIN_USER" ] && echo "[ERROR] WP_ADMIN_USER not set!" && exit 1
[ -z "$WP_ADMIN_EMAIL" ] && echo "[ERROR] WP_ADMIN_EMAIL not set!" && exit 1

[ -z "$DB_HOST" ] && echo "[ERROR] DB_HOST not set!" && exit 1
[ -z "$DB_NAME" ] && echo "[ERROR] DB_NAME not set!" && exit 1
[ -z "$DB_USER" ] && echo "[ERROR] DB_USER not set!" && exit 1

[ -z "$DB_PASSWORD" ] && echo "[ERROR] DB_PASSWORD empty!" && exit 1
[ -z "$WP_ADMIN_PASSWORD" ] && echo "[ERROR] WP_ADMIN_PASSWORD empty!" && exit 1
[ -z "$REDIS_PASSWORD" ] && echo "[ERROR] REDIS_PASSWORD empty!" && exit 1

echo "[INFO] All variables loaded successfully."
echo "[INFO] Starting WordPress setup..."

# ========== Runtime & Directory Setup ==========

PHP_RUN_DIR="/run/php"

mkdir -p "$PHP_RUN_DIR"
chown -R www-data:www-data "$PHP_RUN_DIR"
chown -R www-data:www-data "$WP_PATH"

## ================== Config File Setup ==================

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "[INFO] wp-config.php not found. Creating..."

    wp config create \
      --dbname="$DB_NAME" \
      --dbuser="$DB_USER" \
      --dbpass="$DB_PASSWORD" \
      --dbhost="$DB_HOST" \
      --path="$WP_PATH" \
      --skip-check \
      --allow-root
else
    echo "[INFO] wp-config.php already exists."
fi

# ========== Configure Redis Settings (Bonus) ==========

WP_REDIS_PORT=${REDIS_PORT}
WP_REDIS_HOST=${REDIS_HOST}
WP_CACHE="true"
WP_REDIS_DATABASE=0

[ -z "$WP_REDIS_PORT" ] && echo "[ERROR] WP_REDIS_PORT empty" && exit 1
[ -z "$WP_REDIS_HOST" ] && echo "[ERROR] WP_REDIS_HOST empty" && exit 1

echo "[INFO] Configuring Redis in wp-config.php..."

# Set Host (Container name)
wp config set WP_REDIS_HOST "$WP_REDIS_HOST" --allow-root --type=constant > "$BLACK_HOLE" 2>&1

# Set Port
wp config set WP_REDIS_PORT "$WP_REDIS_PORT" --raw --allow-root --type=constant > "$BLACK_HOLE" 2>&1

# Set Password
wp config set WP_REDIS_PASSWORD "$REDIS_PASSWORD" --allow-root --type=constant > "$BLACK_HOLE" 2>&1

# Enable Cache
wp config set WP_CACHE "$WP_CACHE" --raw --allow-root --type=constant > "$BLACK_HOLE" 2>&1

# Set Database Index
wp config set WP_REDIS_DATABASE "$WP_REDIS_DATABASE" --raw --allow-root --type=constant > "$BLACK_HOLE" 2>&1

# ========== Wait for MariaDB ==========


echo "[INFO] Waiting for MariaDB connection..."
until wp db check --path="$WP_PATH" --allow-root > "$BLACK_HOLE" 2>&1; do
    echo "[WAIT] MariaDB is not reachable yet..."
    sleep 3
done

echo "[SUCCESS] Connected to MariaDB."

# ================== WordPress Installation Check ==================


if ! wp core is-installed --path="$WP_PATH" --allow-root; then
    echo "[INFO] WordPress tables are missing. Installing..."

    wp core install \
      --url="https://$DOMAIN_NAME" \
      --title="$WP_TITLE" \
      --admin_user="$WP_ADMIN_USER" \
      --admin_password="$WP_ADMIN_PASSWORD" \
      --admin_email="$WP_ADMIN_EMAIL" \
      --path="$WP_PATH" \
      --skip-email \
      --allow-root

    echo "[INFO] Updating site options..."
    wp option update blog description "Just another WordPress site" --path="$WP_PATH" --allow-root

    echo "[SUCCESS] WordPress installation completed."
else
    echo "[INFO] WordPress is already installed. Skipping installation."
fi

# ================== Redis Plugin Setup (Bonus) ==================

echo "[INFO] Checking Redis plugin status..."
if ! wp plugin is-installed redis-cache --path="$WP_PATH" --allow-root; then
    echo "[INFO] Installing Redis plugin..."
    wp plugin install redis-cache --activate --path="$WP_PATH" --allow-root
else
    echo "[INFO] Redis plugin is installed. Ensuring activation..."
    wp plugin activate redis-cache --path="$WP_PATH" --allow-root
fi

echo "[INFO] Enabling Redis object cache..."
wp redis enable --path="$WP_PATH" --allow-root

# ================== Start Server ==================

echo "[INFO] Resetting permissions before startup..."
chown -R www-data:www-data "$WP_PATH"

echo "[INFO] Starting PHP-FPM..."
exec php-fpm -F
