FROM nginx:1.21.6-alpine-perl

ENV PROJECT_ROOT=/data/websites  \
    USER="www-data" \
    GROUP_NAME="www-data" \
    FPM_GID=82 \
    FPM_UID=82


RUN set -x \
    &&  sed -i "s@https://dl-cdn.alpinelinux.org/@https://mirrors.huaweicloud.com/@g" /etc/apk/repositories \
     && apk add -U --no-cache \
        busybox-suid \
           shadow \
           bash \
    && mkdir -p ${PROJECT_ROOT} \
    && (deluser www-data || true) \
    && (delgroup www-data || true) \
    && addgroup -g $FPM_GID -S $GROUP_NAME \
    &&  adduser -u $FPM_UID -S -D -H  -G $GROUP_NAME $USER \
    && sed -i -e "s@user\s*nginx@user ${USER}  ${GROUP_NAME}@" /etc/nginx/nginx.conf 

COPY docker-entrypoint.sh /

WORKDIR $PROJECT_ROOT