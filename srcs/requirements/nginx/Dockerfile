FROM debian:bookworm-slim

EXPOSE 443

# ====== Install Dependencies ======

RUN apt-get update && \
    apt-get install -y --fix-missing --no-install-recommends \
    nginx \
    openssl \
    curl \
    && mkdir -p /var/run/nginx /etc/nginx/ssl \
    && rm -rf /var/lib/apt/lists/*


# =========== Execute Configurations ===========

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/installer.sh /usr/local/bin/nginx_installer.sh
RUN chmod +x /usr/local/bin/nginx_installer.sh

ENTRYPOINT ["/usr/local/bin/nginx_installer.sh"]
CMD ["nginx", "-g", "daemon off;"]
