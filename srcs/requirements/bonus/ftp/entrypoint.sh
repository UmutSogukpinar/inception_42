#!/bin/sh

set -e

# ===== Load FTP User =====

FTP_USER=${FTP_USER}

# ========== Load FTP Password ==========

if [ -f "/run/secrets/ftp_password" ]; then
    FTP_PASSWORD=$(cat /run/secrets/ftp_password)

    if [ -z ${FTP_PASSWORD} ]; then
        echo "[ERROR] Ftp password cannot be empty!"
        exit 1
    fi

    echo "[INFO] Password found. Starting with password protection."
else
    echo "[ERROR] Secret file not found!"
    exit 1
fi

# ========== Check if FTP user exists ==========

BLACK_HOLE="/dev/null"

if id "$FTP_USER" > "$BLACK_HOLE" 2>&1; then
    echo "[INFO] FTP user '$FTP_USER' already exists. Skipping creation."
else
    echo "[INFO] Creating FTP user: $FTP_USER"
    
    # ========== Add user ==========

    adduser -D -h /var/www/html "$FTP_USER"
    
    # Set password
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    
    # Add user to vsftpd whitelist
    echo "$FTP_USER" >> /etc/vsftpd.userlist
    
    # Fix ownership to allow write permissions
    chown -R "$FTP_USER:$FTP_USER" /var/www/html
fi

# ========== Start vsftpd ==========

echo "[INFO] Starting vsftpd..."
exec /usr/sbin/vsftpd /etc/vsftpd.conf
