FROM debian:bullseye

# Install Prometheus and dependencies
RUN apt-get update && \
    apt-get install -y prometheus wget \
    curl \
    && \
    rm -rf /var/lib/apt/lists/*

# Copy custom Prometheus configuration file
COPY conf/prometheus.yml /etc/prometheus/prometheus.yml

# Create a dedicated user for Prometheus
RUN mkdir -p /var/lib/prometheus && \
    chown -R prometheus:prometheus /var/lib/prometheus

# Switch to the prometheus user for security
USER prometheus


EXPOSE 9090

# Start Prometheus
ENTRYPOINT ["prometheus", \
            "--config.file=/etc/prometheus/prometheus.yml", \
            "--storage.tsdb.path=/var/lib/prometheus", \
            "--web.console.libraries=/usr/share/prometheus/console_libraries", \
            "--web.console.templates=/usr/share/prometheus/consoles"]