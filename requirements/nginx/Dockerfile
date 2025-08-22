FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx openssl curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl /run/nginx /var/www/html
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/installer.sh /usr/local/bin/installer.sh
RUN chmod +x /usr/local/bin/installer.sh

# Simple index for quick test
RUN echo "<h1>NGINX UP</h1>" > /var/www/html/index.html

EXPOSE 80 443
ENTRYPOINT ["/usr/local/bin/installer.sh"]
CMD ["nginx", "-g", "daemon off;"]
