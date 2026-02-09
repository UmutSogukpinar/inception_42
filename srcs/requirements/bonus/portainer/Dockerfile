FROM alpine:3.22

ARG PORTAINER_VERSION=2.21.5
ARG DOCKER_COMPOSE_VERSION=2.29.1

# Install Dependencies
RUN apk update && apk add --no-cache \
    curl \
    tar \
    ca-certificates \
    libc6-compat \
    gcompat

WORKDIR /tmp
RUN curl -L \
        https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-linux-amd64.tar.gz \
        -o portainer.tar.gz \
    && tar xz -f portainer.tar.gz \
    && mkdir -p /opt/portainer \
    && cp -r portainer/* /opt/portainer/ \
    && rm -rf portainer.tar.gz portainer

# Docker Compose Installation
RUN curl -L \
        https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64 \
        -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Configurations
WORKDIR /opt/portainer
RUN mkdir -p /data
EXPOSE 9443

# Container Entrypoint
ENTRYPOINT ["./portainer", "--data", "/data"]
