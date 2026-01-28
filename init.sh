#!/bin/sh

set -e

USER_NAME="${USER:-umut}"
DATA_DIR="/home/$USER_NAME/data"

echo "[INFO] Ensuring data directories exist under: $DATA_DIR"

mkdir -p "$DATA_DIR/mariadb"
mkdir -p "$DATA_DIR/wordpress"
mkdir -p "$DATA_DIR/redis"
mkdir -p "$DATA_DIR/prometheus"
mkdir -p "$DATA_DIR/grafana"

echo "[SUCCESS] Directories ready:"
echo "  - $DATA_DIR/mariadb"
echo "  - $DATA_DIR/wordpress"
echo "  - $DATA_DIR/redis"
echo "  - $DATA_DIR/prometheus"
echo "  - $DATA_DIR/grafana"
