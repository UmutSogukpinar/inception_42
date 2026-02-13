#!/bin/sh

set -e

echo "[INFO] Starting Redis..."

# ========== Load Variables ==========

CONF_FILE="/etc/redis/redis.conf"

echo "[INFO] Configuring Redis..."

# ========== Load password from secret ==========
: "${SECRET_FILE:?SECRET_FILE is not set}"

if [ -f "$SECRET_FILE" ] && [ -r "$SECRET_FILE" ]; then
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
