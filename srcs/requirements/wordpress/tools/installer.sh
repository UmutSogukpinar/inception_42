#!/bin/sh
set -e

# ======================= Secrets and Credentials ==========================

# Read the database user password from Docker secrets
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# Read the WordPress database user from Docker secrets
WORDPRESS_DB_USER=$(cat /run/secrets/db_user)

# Read the WordPress admin password from Docker secrets
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)

echo "Starting WordPress installation process..."

# ======================= Check Existing Installation ======================

# If wp-config.php already exists, WordPress is considered installed
if [ -f ./wp-config.php ]; then
    echo "WordPress is already installed. Skipping download and configuration."
    exec "$@"
fi

# If partial WordPress files exist, clean them up to avoid conflicts
if [ -d ./wp-admin ] || [ -d ./wp-content ] || [ -d ./wp-includes ]; then
  echo "Partial WordPress files detected. Cleaning up old files..."
  rm -rf ./wp-admin ./wp-content ./wp-includes
fi

# ======================= Download and Extract WordPress ===================

echo "Downloading WordPress core files..."
wget -q http://wordpress.org/latest.tar.gz

echo "Extracting WordPress core files..."
tar xfz latest.tar.gz
mv wordpress/* .

# Remove downloaded archive and temporary folder
rm -rf latest.tar.gz wordpress

# ======================= Install WP-CLI if Missing ========================

if ! command -v wp &> /dev/null; then
  echo "WP-CLI not found. Installing..."
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv wp-cli.phar /usr/local/bin/wp

  # Verify WP-CLI installation
  php /usr/local/bin/wp --info || { echo "Error: WP-CLI installation failed."; exit 1; }
fi

# ======================= Configure wp-config.php ==========================

wp config create    --dbname=$WORDPRESS_DB_NAME \
                    --dbuser=$WORDPRESS_DB_USER \
                    --dbpass=$MYSQL_PASSWORD    \
                    --dbhost=$WORDPRESS_DB_HOST \
                    --skip-check                \
                    --allow-root

# ======================= Install WordPress ================================

wp core install --url="https://usogukpi.42.fr" \
                --title="$WP_TITLE" \
                --admin_user="$WP_ADMIN" \
                --admin_password="$WP_ADMIN_PASSWORD" \
                --admin_email="$WP_ADMIN_EMAIL" \
                --allow-root

# Update WordPress site title and description
wp option update blogname "$WP_TITLE" --allow-root
wp option update blogdescription "Just another WordPress site" --allow-root

# ======================= Execute Container CMD ============================
# Execute the container's default command after installation is complete
exec "$@"
