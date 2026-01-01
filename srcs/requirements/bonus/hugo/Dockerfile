FROM alpine:3.18

# Hugo ve gerekli araçları kur
RUN apk update && apk add --no-cache \
    hugo \
    git \
    shadow \
    bash

# Scripti kopyala
COPY init.sh /hugo_setup.sh
RUN chmod +x /hugo_setup.sh

# Çalışma dizinini ayarla
WORKDIR /var/hugo

# Portu aç
EXPOSE 1313

ENTRYPOINT ["/hugo_setup.sh"]