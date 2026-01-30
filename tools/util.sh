#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# ================== Variables ==================
USER_NAME="umut"
DATA_DIR="/home/$USER_NAME/data"
# List of services that need persistence
SERVICES=("mariadb" "wordpress" "redis" "prometheus" "grafana")

# ================== Functions ==================

log() { echo -e "\e[34m[INFO]\e[0m $1"; }
success() { echo -e "\e[32m[SUCCESS]\e[0m $1"; }
error() { echo -e "\e[31m[ERROR]\e[0m $1"; }

# Setup directories
init() {
    log "Initializing data directories at: $DATA_DIR"
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

# Wipe everything
clear() {
    error "WARNING: This will permanently delete ALL data in $DATA_DIR"

    if [ -n "$DATA_DIR" ] && [ "$DATA_DIR" != "/" ]; then
        sudo rm -rf "$DATA_DIR"
        success "Data cleared successfully."
    else
        log "Clear operation aborted."
    fi
}

usage() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  --init    Setup required directories for services"
    echo "  --clear   Delete all persisted data"
    echo "  --help    Show this help message"
}

# ================== Main Execution ==================

# Check if no arguments provided
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

case "$1" in
    --init)
        init
        ;;
    --clear)
        clear
        ;;
    --help)
        usage
        ;;
    *)
        error "Invalid option: $1"
        usage
        exit 1
        ;;
esac