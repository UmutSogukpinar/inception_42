FROM alpine:3.22

# ===== Install necessary packages =====

RUN apk add --no-cache \
    vsftpd \
    openssl \
    netcat-openbsd \
    inetutils-ftp

# Create WordPress directory and vsftpd chroot directory
RUN mkdir -p /var/www/html && mkdir -p /var/run/vsftpd/empty

# Copy vsftpd configuration
COPY conf/vsftpd.conf /etc/vsftpd.conf

# Copy and make entrypoint script executable
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose FTP ports
EXPOSE 21
EXPOSE 30000-30009

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
