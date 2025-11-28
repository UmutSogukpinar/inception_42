FROM debian:bullseye

# Install vsftpd and OpenSSL
RUN apt-get update && apt-get install -y --no-install-recommends \
    vsftpd \
    openssl \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Create directory for WordPress files
RUN mkdir -p /var/www/html

# Create secure chroot directory required by vsftpd
RUN mkdir -p /var/run/vsftpd/empty

# Copy configuration file
COPY conf/vsftpd.conf /etc/vsftpd.conf

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 21
EXPOSE 30000-30009

CMD ["/usr/local/bin/entrypoint.sh"]
