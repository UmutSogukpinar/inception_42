FROM alpine:3.22

ENV PROMETHEUS_VERSION=2.49.1

# Install required packages
RUN apk add --no-cache curl tar && \
    addgroup -S prometheus && \
    adduser -S -G prometheus -g prometheus prometheus

RUN curl -LO https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz && \
    tar -xvzf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz && \
    mkdir -p /etc/prometheus /var/lib/prometheus && \
    cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/ && \
    cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/ && \
    cp -R prometheus-${PROMETHEUS_VERSION}.linux-amd64/console_libraries /etc/prometheus/ && \
    cp -R prometheus-${PROMETHEUS_VERSION}.linux-amd64/consoles /etc/prometheus/ && \
    rm -rf prometheus-${PROMETHEUS_VERSION}.linux-amd64*

RUN chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

COPY --chown=prometheus:prometheus conf/prometheus.yml /etc/prometheus/prometheus.yml

USER prometheus
EXPOSE 9090

ENTRYPOINT ["prometheus", \
            "--config.file=/etc/prometheus/prometheus.yml", \
            "--storage.tsdb.path=/var/lib/prometheus", \
            "--web.console.libraries=/etc/prometheus/console_libraries", \
            "--web.console.templates=/etc/prometheus/consoles"]
