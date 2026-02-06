FROM alpine:3.22

RUN apk update && apk add --no-cache \
    hugo \
    git \
    shadow \
    bash


COPY init.sh /hugo_setup.sh
RUN chmod +x /hugo_setup.sh


WORKDIR /var/hugo


EXPOSE 1313

ENTRYPOINT ["/hugo_setup.sh"]