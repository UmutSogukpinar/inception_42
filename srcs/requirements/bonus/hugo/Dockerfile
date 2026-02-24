FROM alpine:3.22

# =========== Install Dependencies ===========
RUN apk update && apk add --no-cache \
    hugo \
    git \
    shadow \
    bash \
	wget

#  =========== Execute Configurations ===========
    
COPY content/content.sh /usr/local/bin/hugo_setup.sh
RUN chmod +x /usr/local/bin/hugo_setup.sh

ENTRYPOINT ["/usr/local/bin/hugo_setup.sh"]
