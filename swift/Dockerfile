FROM php:7.3-apache

ENV DEBIAN_FRONTEND="noninteractive"

RUN mkdir -p /usr/share/man/man1 && apt-get update
RUN apt-get install -y libreadline-dev libxpm4 libxpm-dev libjpeg-dev libfreetype6-dev libssl-dev \
       mariadb-client wget git procps unzip curl \
       ${PHPIZE_DEPS} libmcrypt-dev libpng-dev libc-client-dev libkrb5-dev libzip-dev \
       gnupg1 apt-transport-https sudo python3 python3-pip

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN echo "deb https://download.docker.com/linux/debian stretch stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce file binutils
RUN docker-php-ext-configure gd --with-gd --with-jpeg-dir --with-freetype-dir
RUN docker-php-ext-install mysqli pdo_mysql gd zip
RUN docker-php-ext-install opcache
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install imap

RUN curl -Lso- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; return 0

RUN echo "[mysql]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\ndatabase=swift\n\n[mysqladmin]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\n\n[mysqldump]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\n" > ~/.my.cnf

RUN echo 'echo "*** TO INSTALL SWIFT USE ***\n\ncd setup;php console.setup.php Trilogy \"http%3A%2F%2Fkayako-dev%2F\" Kayako Admin admin admin virlatinus%40gmail.com\n\n"' > ~/.bashrc

RUN useradd -G www-data -u 1000 wgarcia
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

## Install internationalization
RUN apt-get install -y icu-devtools libicu-dev
RUN docker-php-ext-install intl

## Clean up
RUN apt-get remove -y --purge ${PHPIZE_DEPS}
RUN apt-get autoremove -y
RUN apt-get clean -y

RUN rm -rf /usr/src/* /tmp/*
