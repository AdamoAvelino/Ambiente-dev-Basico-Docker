FROM php:7.3-apache
WORKDIR /var/www/html
RUN mkdir /var/www/html/public
COPY .docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN docker-php-ext-install pdo pdo_mysql
RUN a2enmod rewrite
RUN service apache2 restart
