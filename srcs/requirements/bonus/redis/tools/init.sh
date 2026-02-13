#!/bin/sh

set -e

echo "[INFO] Starting Redis..."

# ========== Variables ==========

CONF_FILE="/etc/redis/redis.conf"
SECRET_FILE="/run/secrets/redis_password"

echo "[INFO] Configuring Redis..."

# ========== Load password from secret ==========

if [ -r "$SECRET_FILE" ] && [ -f "$SECRET_FILE" ]; then
    REDIS_PASSWORD="$(tr -d '\r\n' < "$SECRET_FILE")"

    if [ -z "$REDIS_PASSWORD" ]; then
        echo "[ERROR] Secret file is empty: $SECRET_FILE"
        exit 1
    fi

    echo "[INFO] Redis password loaded from secret file."
else
    echo "[ERROR] Secret file is missing or not readable: $SECRET_FILE"
    exit 1
fi


# ================== Start Redis Server ==================

exec redis-server "$CONF_FILE" --requirepass "$REDIS_PASSWORD"
