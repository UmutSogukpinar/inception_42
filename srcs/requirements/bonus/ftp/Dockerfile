FROM alpine:3.20

# ===== Install necessary packages =====

RUN apk add --no-cache \
    vsftpd \
    openssl \
    netcat-openbsd

# Create WordPress directory
RUN mkdir -p /var/www/html

# Create secure chroot directory for vsftpd
RUN mkdir -p /var/run/vsftpd/empty

# Copy vsftpd configuration
COPY conf/vsftpd.conf /etc/vsftpd.conf

# Copy and make entrypoint script executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose FTP ports
EXPOSE 21
EXPOSE 30000-30009

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
