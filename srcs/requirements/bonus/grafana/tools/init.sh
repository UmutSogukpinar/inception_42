#!/bin/sh

# Stop execution on any error
set -e

echo "[INFO] Starting Grafana Setup..."

# Path to the secret file
SECRET_FILE="/run/secrets/grafana_admin_password"

# Check if the secret file exists
if [ -f "$SECRET_FILE" ]; then
    export GF_SECURITY_ADMIN_PASSWORD=$(cat "$SECRET_FILE")
    echo "[INFO] Admin password set from secret."
else
    echo "[WARNING] Secret file not found. Using default or existing config."
fi

# Start Grafana server
echo "[INFO] Starting Grafana Server..."

exec /usr/sbin/grafana-server \
    --config=/etc/grafana/grafana.ini \
    --homepath=/usr/share/grafana \
    cfg:default.paths.data=/var/lib/grafana \
    cfg:default.paths.logs=/var/lib/grafana/logs \
    cfg:default.paths.plugins=/var/lib/grafana/plugins