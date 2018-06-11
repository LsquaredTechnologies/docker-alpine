FROM alpine:latest
RUN apk add --update --no-cache bash tzdata xz
ADD mkimage-alpine.sh /
ADD rootfs /var/tmp/rootfs
RUN chmod a+x /mkimage-alpine.sh
ENTRYPOINT ["/mkimage-alpine.sh"]
