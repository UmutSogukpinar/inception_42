#!/bin/sh

set -e

# ===== Load FTP User =====

FTP_USER=${FTP_USER}

# ===== Load FTP Password =====

# Prefer Docker secret, fallback to env var or default
if [ -f "/run/secrets/ftp_password" ]; then
    FTP_PASSWORD=$(cat /run/secrets/ftp_password)
else
    FTP_PASSWORD=${FTP_PASSWORD:-"admin123"}
    echo "[WARNING] Secret not found, using Environment/Default password."
fi

# ===== Check if FTP user exists =====

if id "$FTP_USER" >/dev/null 2>&1; then
    echo "[INFO] FTP user '$FTP_USER' already exists. Skipping creation."
else
    echo "[INFO] Creating FTP user: $FTP_USER"
    
    # ===== Add user =====

    # -D disables password prompt, -h sets home directory
    adduser -D -h /var/www/html "$FTP_USER"
    
    # Set password
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    
    # Add user to vsftpd whitelist
    echo "$FTP_USER" >> /etc/vsftpd.userlist
    
    # Fix ownership to allow write permissions
    chown -R "$FTP_USER:$FTP_USER" /var/www/html
fi

# ===== Start vsftpd =====
echo "[INFO] Starting vsftpd..."
exec /usr/sbin/vsftpd /etc/vsftpd.conf
