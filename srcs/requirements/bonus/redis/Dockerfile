FROM alpine:3.22

# ======= Install Dependencies =======

RUN apk add --no-cache redis \
 && mkdir -p /etc/redis /var/run/redis \
 && chown -R redis:redis /var/run/redis /etc/redis \
 && chmod 777 /var/run/redis

# =========== Execute Configurations ===========

COPY conf/redis.conf /etc/redis/redis.conf
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

ENTRYPOINT ["/usr/local/bin/init.sh"]
