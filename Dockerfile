ARG PHP_VERSION=7.4

FROM php:${PHP_VERSION}-fpm-alpine

LABEL maintainer="zhujiayan <xz@zjybb.com>"

ARG TZ=Asia/Shanghai
ENV TZ ${TZ}

RUN apk update && \
    pecl channel-update pecl.php.net && \
    apk --no-cache add curl tree tzdata libzip-dev zip unzip && \
    cp /usr/share/zoneinfo/${TZ} /etc/localtime

RUN docker-php-ext-install opcache pcntl bcmath exif mysqli pdo_mysql && \
    apk --no-cache add icu-dev cmake && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl && \
    docker-php-ext-configure zip \
    docker-php-ext-install zip \
    pecl install -o -f redis && \
    docker-php-ext-enable redis && \
    pecl install mongodb && \
    docker-php-ext-enable mongodb && \
    pecl install protobuf && \
    docker-php-ext-enable protobuf && \
    pecl install swoole && \
    docker-php-ext-enable swoole && \
    rm -rf /tmp/pear && \
    rm -rf /var/cache/apk/*

COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY ./pool.ini /usr/local/etc/php/conf.d/pool.ini
COPY ./php.ini /usr/local/etc/php/php.ini

EXPOSE 9000

WORKDIR /var/www

CMD [ "php-fpm" ]