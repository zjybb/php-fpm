ARG PHP_VERSION=7.3

FROM php:${PHP_VERSION}-fpm-alpine

LABEL maintainer="zhujiayan <xz@zjybb.com>"

ARG TZ=Asia/Shanghai
ENV TZ ${TZ}

# install soft and set time
RUN apk update \
    && apk --no-cache add curl tree tzdata postgresql-dev postgresql-client icu-dev libzip-dev libjpeg-turbo-dev libpng-dev freetype-dev\
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && rm -rf /var/cache/apk/*

# php ext
RUN docker-php-ext-install opcache pcntl bcmath exif \
    mysqli pdo_mysql pdo_pgsql pgsql \
    # gd
    && docker-php-ext-configure gd \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2 \
    && docker-php-ext-install gd \
    # icu
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    # zip
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install zip \
    # pecl
    && apk --no-cache add gcc g++ make autoconf \
    && pecl channel-update pecl.php.net \
    # redis
    && printf "\n" | pecl install -o -f redis \
    && docker-php-ext-enable redis \
    # mongo
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    # protobuf
    && pecl install protobuf \
    && docker-php-ext-enable protobuf \
    # swoole
    && pecl install swoole \
    && docker-php-ext-enable swoole \
    # clear cache
    && apk del gcc g++ make autoconf \
    && rm -rf /tmp/pear \
    && rm -rf /var/cache/apk/*


COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY ./pool.ini /usr/local/etc/php/conf.d/pool.ini
COPY ./php.ini /usr/local/etc/php/php.ini

EXPOSE 9000

CMD [ "php-fpm" ]