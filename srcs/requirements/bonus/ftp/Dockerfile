FROM alpine:3.22

EXPOSE 21
EXPOSE 30000-30009

# ===== Install necessary packages =====

RUN apk add --no-cache \
    vsftpd \
    openssl \
    netcat-openbsd \
    inetutils-ftp

# ==== Execute Configurations ====
    
RUN mkdir -p /var/www/html && mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
