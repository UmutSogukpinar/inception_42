#!/bin/bash

set -euo pipefail

# ================== Variables ==================

USER_NAME="usogukpi"
DATA_DIR="/home/$USER_NAME/data"
SERVICES=("mariadb" "wordpress" "redis" "portainer")

# ================== Functions ==================

log() { echo -e "\e[34m[INFO]\e[0m $1"; }
success() { echo -e "\e[32m[SUCCESS]\e[0m $1"; }
error() { echo -e "\e[31m[ERROR]\e[0m $1"; }

usage() 
{
    echo "Usage: $0 {--init}"
    echo "  --init: Setup data directories for services."
}

init() 
{
    log "Initializing data directories at: $DATA_DIR"
    if [ ! -w "$(dirname "$DATA_DIR")" ]; then
        error "Error: No write permission on $(dirname "$DATA_DIR")"
        exit 1
    fi

    for service in "${SERVICES[@]}"; do
        target="$DATA_DIR/$service"
        if [ ! -d "$target" ]; then
            mkdir -p "$target"
            success "Created: $target"
        else
            log "Exists: $target (Skipping)"
        fi
    done
    success "Environment initialization complete."
}

# ================== Main Execution ==================

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

case "$1" in
    --init)
        init
        ;;
    *)
        error "Invalid option: $1"
        usage
        exit 1
        ;;
esac