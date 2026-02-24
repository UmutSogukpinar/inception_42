#!/bin/sh

set -e

echo "[INFO] Starting Redis..."

# ========== Load Variables ==========

CONF_FILE="/etc/redis/redis.conf"

echo "[INFO] Configuring Redis..."

# ========== Load password from secret ==========

: "${REDIS_PASSWORD_FILE:?REDIS_PASSWORD_FILE is not set}"

if [ -f "$REDIS_PASSWORD_FILE" ] && [ -r "$REDIS_PASSWORD_FILE" ]; then
    REDIS_PASSWORD="$(tr -d '\r\n' < "$REDIS_PASSWORD_FILE")"

    if [ -z "$REDIS_PASSWORD" ]; then
        echo "[ERROR] REDIS_PASSWORD_FILE is empty: $REDIS_PASSWORD_FILE"
        exit 1
    fi

    echo "[INFO] Redis password loaded from secret file."
else
    echo "[ERROR] REDIS_PASSWORD_FILE is missing or not readable: $REDIS_PASSWORD_FILE"
    exit 1
fi

# ================== Start Redis Server ==================

exec redis-server "$CONF_FILE" --requirepass "$REDIS_PASSWORD"
