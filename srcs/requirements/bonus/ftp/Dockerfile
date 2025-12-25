FROM alpine:3.19

# Install vsftpd and required tools
RUN apk add --no-cache \
    vsftpd \
    openssl \
    netcat-openbsd

# Create directory for WordPress files
RUN mkdir -p /var/www/html

# Create secure chroot directory required by vsftpd
RUN mkdir -p /var/run/vsftpd/empty

# Copy configuration file
COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 21
EXPOSE 30000-30009

CMD ["/usr/local/bin/entrypoint.sh"]
