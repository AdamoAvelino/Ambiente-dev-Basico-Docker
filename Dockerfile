FROM php:7.4-apache

WORKDIR /var/www/html
COPY .docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN apt update -y && \
    apt install apt-utils build-essential systemd net-tools curl locales git zip unzip nano vim -y

RUN apt install -y libpq-dev libfreetype6-dev libpng-dev zlib1g-dev \
        libzip-dev graphviz libpspell-dev aspell-en libmcrypt-dev libicu-dev libxml2-dev libldap2-dev  \
        libssl-dev libxslt-dev libkrb5-dev libldb-dev libcurl3-dev \
        libsnmp-dev librecode0 librecode-dev libbz2-dev libc-client-dev

RUN docker-php-ext-configure gd && \
    docker-php-ext-install gd && \
    docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-install pdo pdo_mysql

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

RUN mkdir -p docker/php/conf.d && \
    touch docker/php/conf.d/xdebug.ini && \
    touch docker/php/conf.d/error_reporting.ini

RUN echo "zend_extension=xdebug" >> docker/php/conf.d/xdebug.ini && \
    echo "[xdebug]" >> docker/php/conf.d/xdebug.ini && \
    echo "xdebug.mode=develop,debug" >> docker/php/conf.d/xdebug.ini && \
    echo "xdebug.client_host=host.docker.internal" >> docker/php/conf.d/xdebug.ini && \
    echo "xdebug.start_with_request=yes" >> docker/php/conf.d/xdebug.ini

RUN cd ~ && \
    curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN pecl install ds && \
    docker-php-ext-enable ds

RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

RUN passwd -d www
COPY --chown=www:www . /var/www/html

RUN a2enmod rewrite && service apache2 restart
