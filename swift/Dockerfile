FROM php:7.3-apache

ENV DEBIAN_FRONTEND="noninteractive"

RUN mkdir -p /usr/share/man/man1 && apt-get update
RUN apt-get install -y libreadline-dev libxpm4 libxpm-dev libjpeg-dev libfreetype6-dev libssl-dev \
       mariadb-client wget git procps unzip curl \
       ${PHPIZE_DEPS} libmcrypt-dev libpng-dev libc-client-dev libkrb5-dev libzip-dev \
       gnupg1 apt-transport-https sudo python3 python3-pip

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN echo "deb https://download.docker.com/linux/debian stretch stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce file binutils
RUN docker-php-ext-configure gd --with-gd --with-jpeg-dir --with-freetype-dir
RUN docker-php-ext-install mysqli pdo_mysql gd zip
RUN docker-php-ext-install opcache
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install imap

RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

## Install internationalization
RUN apt-get install -y icu-devtools libicu-dev
RUN docker-php-ext-install intl

## Clean up
RUN apt-get remove -y --purge ${PHPIZE_DEPS}
RUN apt-get autoremove -y
RUN apt-get clean -y

RUN rm -rf /usr/src/* /tmp/*

## Configure PHP settings
RUN perl -pi -e 's[;(date.timezone =).*][\1 "UTC"]' /usr/local/etc/php/php.ini
RUN perl -pi -e 's[memory_limit = 128M][memory_limit = -1]' /usr/local/etc/php/php.ini
# disable sendmail during tests
RUN perl -pi -e "s[^.*sendmail_path.*$][sendmail_path = /bin/false]" /usr/local/etc/php/php.ini

## Install composer
RUN curl -Lso- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; return 0

## Setup MySQL client
RUN echo "[mysql]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\ndatabase=swift\n\n[mysqladmin]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\n\n[mysqldump]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\n" > ~/.my.cnf

RUN echo "alias xdebug-on=\"docker-php-ext-enable xdebug\"" >> ~/.bashrc
RUN echo "alias xdebug-off=\"php -i|grep xdebug.ini|sed 's/.$//'|xargs rm\"" >> ~/.bashrc

ARG USER

RUN useradd -g www-data -d /var/www/html $USER
 
# Map SWIFT trunk directory to this volume
VOLUME /var/www/html
WORKDIR /var/www/html

RUN umask 002
