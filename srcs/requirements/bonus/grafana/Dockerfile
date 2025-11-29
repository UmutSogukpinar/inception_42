FROM debian:bullseye

# Install Dependencies
RUN apt-get update && apt-get install -y \
    wget \
    adduser \
    libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*

# Download and Install Grafana directly (.deb package)
RUN wget https://dl.grafana.com/oss/release/grafana_9.5.2_amd64.deb && \
    dpkg -i grafana_9.5.2_amd64.deb && \
    rm grafana_9.5.2_amd64.deb

# Setup Provisioning Directory
RUN mkdir -p /etc/grafana/provisioning/datasources

# Copy Config Files
COPY conf/datasource.yaml /etc/grafana/provisioning/datasources/datasource.yaml
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# 5. Set Permissions
RUN mkdir -p /var/lib/grafana && \
    chown -R grafana:grafana /var/lib/grafana /etc/grafana

# Set Environment Variables for Grafana Paths
ENV GF_PATHS_PROVISIONING=/etc/grafana/provisioning

# Expose Port
EXPOSE 3000

# Run as user grafana
USER grafana
WORKDIR /usr/share/grafana

# Start via Script
ENTRYPOINT ["/usr/local/bin/init.sh"]