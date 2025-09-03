#!/bin/sh
set -e

# Environment expected:
# WP_DB_HOST, WP_DB_NAME, WP_DB_USER, WP_DB_PASSWORD
# WP_TABLE_PREFIX (optional, default: wp_)
# WP_SITE_URL, WP_SITE_TITLE, WP_ADMIN_USER, WP_ADMIN_PASSWORD, WP_ADMIN_EMAIL
# (If install params are missing, script will just prepare files and skip core install.)

WEBROOT="/var/www/html"
WP_CLI="/usr/local/bin/wp"

# Install wp-cli if missing
if [ ! -x "$WP_CLI" ]; then
  curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o "$WP_CLI"
  chmod +x "$WP_CLI"
fi

# Download WordPress if not present
if [ ! -f "$WEBROOT/wp-settings.php" ]; then
  echo "[wp-entrypoint] Downloading WordPress..."
  curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz
  tar -xzf /tmp/wordpress.tar.gz -C /tmp
  rm -rf "$WEBROOT"/* 2>/dev/null || true
  mv /tmp/wordpress/* "$WEBROOT"/
  rm -rf /tmp/wordpress /tmp/wordpress.tar.gz
  chown -R www-data:www-data "$WEBROOT"
fi

# Create wp-config.php if not exists
if [ ! -f "$WEBROOT/wp-config.php" ]; then
  echo "[wp-entrypoint] Generating wp-config.php..."
  DB_HOST="${WP_DB_HOST:-mariadb:3306}"
  DB_NAME="${WP_DB_NAME:-wordpress}"
  DB_USER="${WP_DB_USER:-wpuser}"
  DB_PASS="${WP_DB_PASSWORD:-wppass}"
  TABLE_PREFIX="${WP_TABLE_PREFIX:-wp_}"

  # Generate salts
  SALTS="$(curl -fsSL https://api.wordpress.org/secret-key/1.1/salt/ || true)"

  cat > "$WEBROOT/wp-config.php" <<EOF
<?php
define('DB_NAME', '${DB_NAME}');
define('DB_USER', '${DB_USER}');
define('DB_PASSWORD', '${DB_PASS}');
define('DB_HOST', '${DB_HOST}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

${SALTS}

\$table_prefix = '${TABLE_PREFIX}';

define('WP_DEBUG', false);
if ( !defined('ABSPATH') ) {
  define('ABSPATH', __DIR__ . '/');
}
require_once ABSPATH . 'wp-settings.php';
EOF

  chown www-data:www-data "$WEBROOT/wp-config.php"
fi

# If install parameters are present and site not installed, perform automated install
if [ -n "$WP_SITE_URL" ] && [ -n "$WP_SITE_TITLE" ] \
   && [ -n "$WP_ADMIN_USER" ] && [ -n "$WP_ADMIN_PASSWORD" ] && [ -n "$WP_ADMIN_EMAIL" ]; then

  # Wait for DB
  echo "[wp-entrypoint] Waiting for database at ${WP_DB_HOST}..."
  ATTEMPTS=30
  until php -r '
    $h = getenv("WP_DB_HOST") ?: "mariadb:3306";
    $p = explode(":", $h);
    $host = $p[0];
    $port = isset($p[1]) ? (int)$p[1] : 3306;
    $s = @fsockopen($host, $port, $errno, $errstr, 2.0);
    if ($s) { fclose($s); exit(0); } exit(1);
  '; do
    ATTEMPTS=$((ATTEMPTS-1))
    if [ "$ATTEMPTS" -le 0 ]; then
      echo "[wp-entrypoint] ERROR: Database is unreachable."
      break
    fi
    sleep 2
  done

  # Check if already installed
  if ! sudo -u www-data -s -- $WP_CLI core is-installed --path="$WEBROOT" --allow-root 2>/dev/null; then
    echo "[wp-entrypoint] Running wp core install..."
    sudo -u www-data -s -- $WP_CLI core install \
      --path="$WEBROOT" \
      --url="$WP_SITE_URL" \
      --title="$WP_SITE_TITLE" \
      --admin_user="$WP_ADMIN_USER" \
      --admin_password="$WP_ADMIN_PASSWORD" \
      --admin_email="$WP_ADMIN_EMAIL" \
      --skip-email \
      --allow-root || true
  fi
fi

# Finally, exec the main process (php-fpm in foreground)
exec "$@"
