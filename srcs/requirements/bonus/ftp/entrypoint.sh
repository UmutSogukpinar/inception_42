#!/bin/sh
set -e

FTP_USER=${FTP_USER}
FTP_PASSWORD=$(cat /run/secrets/ftp_password)

# Check if FTP user already exists
if id "$FTP_USER" >/dev/null 2>&1; then
    echo "[INFO] FTP user '$FTP_USER' already exists. Skipping creation."
else
    echo "[INFO] Creating FTP user: $FTP_USER"
    adduser --disabled-password --gecos "" $FTP_USER
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    usermod -d /var/www/html $FTP_USER
    echo "$FTP_USER" >> /etc/vsftpd.userlist
fi

echo "[INFO] Starting vsftpd..."
exec /usr/sbin/vsftpd /etc/vsftpd.conf
