#!/bin/sh

set -e

# ========== Load FTP Password ==========
: "${FTP_PASSWORD_FILE:?FTP_PASSWORD_FILE is not set}"

if [ ! -f "$FTP_PASSWORD_FILE" ] || [ ! -r "$FTP_PASSWORD_FILE" ]; then
    echo "[ERROR] Secret file is missing or not readable: $FTP_PASSWORD_FILE"
    exit 1
fi

FTP_PASSWORD="$(tr -d '\r\n' < "$FTP_PASSWORD_FILE")"

if [ -z "$FTP_PASSWORD" ]; then
    echo "[ERROR] FTP password cannot be empty!"
    exit 1
fi

echo "[INFO] FTP password loaded from secret file."


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
