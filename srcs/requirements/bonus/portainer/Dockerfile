FROM alpine:3.22

ARG PORTAINER_VERSION=2.33.5

# ==== Install Dependencies ====

RUN apk update && apk add --no-cache \
    curl \
    tar \
    ca-certificates \
    libc6-compat \
    gcompat

RUN curl -fSL \
        https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-linux-amd64.tar.gz \
        -o /tmp/portainer.tar.gz \
    && tar -xzf /tmp/portainer.tar.gz -C /tmp \
    && mkdir -p /opt/portainer \
    && cp -r /tmp/portainer/* /opt/portainer/ \
    && rm -rf /tmp/portainer.tar.gz /tmp/portainer

RUN mkdir -p /opt/portainer/data

# ======== Start Portainer ========

ENTRYPOINT ["/opt/portainer/portainer"]
