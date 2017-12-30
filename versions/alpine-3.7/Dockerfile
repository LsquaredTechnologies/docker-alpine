FROM scratch
ARG RELEASE=${RELEASE:-}
ADD rootfs.tar.xz /
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["/bin/sh"]
LABEL maintainer "Lionel Lalande <lionel@lsquared.fr>"
