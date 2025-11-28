#!/bin/sh

# Stop execution on any error
set -e

CONF_FILE="/etc/redis/redis.conf"
SECRET_FILE="/run/secrets/redis_password"

echo "[INFO] Configuring Redis..."

# Clean up old/default settings
sed -i '/^bind/d' $CONF_FILE
sed -i '/^requirepass/d' $CONF_FILE
sed -i '/^protected-mode/d' $CONF_FILE

# Append new settings


echo "" >> $CONF_FILE 

# Allow connections from any IP
echo "bind 0.0.0.0" >> $CONF_FILE

# Disable protected mode (since we enforce a password)
echo "protected-mode no" >> $CONF_FILE

# Read Password from Docker Secret
if [ -f "$SECRET_FILE" ]; then
    REDIS_PASSWORD=$(cat "$SECRET_FILE")
    
    if [ -n "$REDIS_PASSWORD" ]; then
        echo "requirepass $REDIS_PASSWORD" >> $CONF_FILE
        echo "[INFO] Password set successfully from secret."
    else
        echo "[ERROR] Secret file is empty!"
        exit 1
    fi
else
    echo "[ERROR] Redis password secret not found at $SECRET_FILE!"
    exit 1
fi

echo "[INFO] Starting Redis Server..."

# Start Redis
exec redis-server $CONF_FILE