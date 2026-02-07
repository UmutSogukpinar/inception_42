FROM alpine:3.22

RUN apk update && apk add --no-cache \
    grafana \
    wget \
    bash \
    ca-certificates


RUN mkdir -p /etc/grafana/provisioning/datasources \
             /var/lib/grafana \
             /var/log/grafana

COPY conf/datasource.yaml /etc/grafana/provisioning/datasources/datasource.yaml


COPY conf/grafana.ini /etc/grafana/grafana.ini


COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh


RUN chown -R grafana:grafana /var/lib/grafana \
                             /var/log/grafana \
                             /etc/grafana \
                             /usr/share/grafana

ENV GF_PATHS_CONFIG=/etc/grafana/grafana.ini
ENV GF_PATHS_DATA=/var/lib/grafana
ENV GF_PATHS_LOGS=/var/log/grafana
ENV GF_PATHS_PROVISIONING=/etc/grafana/provisioning

EXPOSE 3000

USER grafana
WORKDIR /usr/share/grafana

ENTRYPOINT ["/usr/local/bin/init.sh"]