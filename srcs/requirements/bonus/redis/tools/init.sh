#!/bin/sh

set -e

# ===== Variables =====

CONF_FILE="/etc/redis/redis.conf"
SECRET_FILE="/run/secrets/redis_password"

echo "[INFO] Configuring Redis..."

# ===== Clean old config lines =====

# Remove existing bind, requirepass, and protected-mode lines to prevent duplicates
sed -i '/^bind/d' "$CONF_FILE"
sed -i '/^requirepass/d' "$CONF_FILE"
sed -i '/^protected-mode/d' "$CONF_FILE"

# ===== Append new settings =====

echo "" >> "$CONF_FILE"
echo "bind 0.0.0.0" >> "$CONF_FILE"           # Allow connections from any IP
echo "protected-mode no" >> "$CONF_FILE"      # Disable protected mode (password enforced)

# ===== Load password from secret =====

if [ -f "$SECRET_FILE" ]; then
    REDIS_PASSWORD=$(cat "$SECRET_FILE")
    if [ -n "$REDIS_PASSWORD" ]; then
        echo "requirepass $REDIS_PASSWORD" >> "$CONF_FILE"
        echo "[INFO] Password set successfully from secret."
    else
        echo "[ERROR] Secret file is empty!"
        exit 1
    fi
else
    echo "[ERROR] Redis password secret not found at $SECRET_FILE!"
    exit 1
fi

# ===== Start Redis server =====

echo "[INFO] Starting Redis Server..."
exec redis-server "$CONF_FILE"
