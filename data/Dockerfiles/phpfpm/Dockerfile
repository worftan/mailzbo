FROM php:8.1.3-fpm-alpine3.15

LABEL maintainer "wolf tan <wolf.tan@zbocloud.com>"

ENV  DOCUMENT_ROOT="/data/websites" \
      APCU_PECL=5.1.21 \
      MSMTP_VERSION=1.8.19 \
      IMAGICK_PECL=3.7.0 \
      MEMCACHED_PECL=3.1.5 \
      REDIS_PECL=5.3.7 \
      IGBINARY_PECL=3.2.7 \
      MSGPACK_PECL=2.1.2 \
      FPM_USER="www-data" \
      FPM_GROUP="www-data" \
      FPM_GID=82 \
      FPM_UID=82


RUN set -eux;sed -i "s@http://dl-cdn.alpinelinux.org/@https://mirrors.huaweicloud.com/@g" /etc/apk/repositories \
    && sed -i "s@https://dl-cdn.alpinelinux.org/@https://mirrors.huaweicloud.com/@g" /etc/apk/repositories \
    && apk add -U --no-cache \
        busybox-suid \
           shadow \
           git \
           proxychains-ng \
         bash \
           jq \
            redis \
          samba-client \
          mysql-client \
         mariadb-dev \
  && userdel  www-data \
  && mkdir -p ${DOCUMENT_ROOT} \
  && addgroup -g $FPM_GID -S $FPM_GROUP \
  &&  adduser -u $FPM_UID -S -D -H  -G $FPM_GROUP $FPM_USER
  
RUN set -eux \
    && apk add  --no-cache --virtual .build-ext-deps  \
     $PHPIZE_DEPS \
  aspell-dev \
  aspell-libs \
  c-client \
  cyrus-sasl-dev \
  freetype \
  freetype-dev \
  gettext-dev \
  gmp-dev \
  gnupg \
  icu-dev \
  icu-libs \
  imagemagick \
  imagemagick-dev \
  imap-dev \
  gettext \
  cmake \
  automake \
  texinfo \
  linux-headers \
  libjpeg-turbo \
  libjpeg-turbo-dev \
  libmemcached-dev \
  libpng \
  libpng-dev \
  libressl \
  libressl-dev \
  librsvg \
  libtool \
  libwebp-dev \
  libxml2-dev \
  libxpm-dev \
  libzip-dev \
  libxslt-dev \
  make \
  openldap-dev \
  pcre-dev \
  gnutls-dev \
  gnutls \
  re2c \
  nghttp2 \
  nghttp2-dev \
  openssl \
  openssl-dev \
  zlib-dev \
  tzdata 
  

RUN set -eux \
  && git clone https://github.com/php/pecl-mail-mailparse \
  && cd pecl-mail-mailparse \
  && pecl install package.xml \
  && pecl channel-update pecl.php.net \
  && cd .. \
  && rm -r pecl-mail-mailparse \
  && pecl install igbinary-${IGBINARY_PECL} msgpack-${MSGPACK_PECL}  imagick-${IMAGICK_PECL} \
  && docker-php-ext-enable igbinary msgpack imagick mailparse \
  && pecl install redis-${REDIS_PECL} memcached-${MEMCACHED_PECL}  apcu-${APCU_PECL} \
  && docker-php-ext-enable  memcached  redis apcu \
  && pecl clear-cache \
  && docker-php-ext-configure intl \
  && docker-php-ext-configure exif \
  && docker-php-ext-configure calendar  \
  && docker-php-ext-configure gd --with-freetype=/usr/include/ \  
    --with-jpeg=/usr/include/ \
  && docker-php-ext-install -j 4 xsl exif gd gettext intl ldap opcache pcntl pdo pdo_mysql pspell soap sockets zip bcmath gmp calendar \
  && docker-php-ext-configure imap --with-imap --with-imap-ssl  \
 # && docker-php-ext-enable calendar \
  && docker-php-ext-install -j 4 imap \
  && curl --silent --show-error https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer \
  && chmod +x /usr/local/bin/composer \
#add swoole
	&& mkdir -p /usr/src/swoole/swoole-src \
	&& cd /usr/src/swoole \
	&& curl -o ./swoole.tar.gz https://github.com/swoole/swoole-src/archive/master.tar.gz -L \
	&& tar -xf swoole.tar.gz -C /usr/src/swoole/swoole-src --strip-components=1  \
	&& docker-php-ext-configure /usr/src/swoole/swoole-src \
  --enable-swoole \
	--enable-openssl \
	--enable-http2 \
	&& docker-php-ext-install /usr/src/swoole/swoole-src \
  && rm -rf /usr/src/swoole
  
RUN set -eux \
 # add msmtp
  &&  mkdir -p /usr/src/msmtp; \
          cd /usr/src; \
           curl -fsSL "https://marlam.de/msmtp/releases/msmtp-${MSMTP_VERSION}.tar.xz" -o /usr/src/msmtp.tar.xz; \
          tar xf msmtp.tar.xz -C /usr/src/msmtp --strip-components=1; \
          cd /usr/src/msmtp; \
        ./configure; make; make install;rm -rf /usr/src/msmtp \
  &&  runDeps="$( \
          scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  )"; \
	apk add --no-cache $runDeps; \
	\
	apk del --no-network .build-ext-deps; \
	# update pecl channel definitions https://github.com/docker-library/php/issues/443
    	pecl update-channels; \
    	rm -rf /tmp/pear ~/.pearrc; \
    	php --version; \
    { \
  echo '#strict_chain'; \
  echo 'dynamic_chain'; \
  echo 'proxy_dns';     \
  echo 'remote_dns_subnet 224'; \
  echo 'tcp_read_time_out 15000'; \
  echo 'tcp_connect_time_out 8000'; \
  echo 'localnet 127.0.0.0/255.0.0.0'; \
  echo 'localnet 172.25.0.0/255.255.0.0'; \
  echo 'quiet_mode'; \
  echo ''; \
  echo '[ProxyList]'; \
  echo 'socks5  177.177.17.254 1880'; \
  } | tee > /etc/proxychains.conf 


COPY ./docker-entrypoint.sh /

WORKDIR ${DOCUMENT_ROOT} 

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["php-fpm"]
