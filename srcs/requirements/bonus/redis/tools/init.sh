#!/bin/sh

set -e

echo "[INFO] Starting Redis..."

# ========== Variables ==========

CONF_FILE="/etc/redis/redis.conf"
SECRET_FILE="/run/secrets/redis_password"

echo "[INFO] Configuring Redis..."

# ========== Load password from secret ==========

if [ -f "$SECRET_FILE" ]; then
    REDIS_PASSWORD=$(cat "$SECRET_FILE")
    
    if [ -z "$REDIS_PASSWORD" ]; then
        echo "[ERROR] Secret file is empty!"
        exit 1
    fi

    echo "[INFO] Password found. Starting with password protection."
else
    echo "[ERROR] No password secret file found!"
    exit 1
fi

# ================== Start Redis Server ==================

exec redis-server "$CONF_FILE" --requirepass "$REDIS_PASSWORD"
