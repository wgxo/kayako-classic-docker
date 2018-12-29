FROM php:7.2-apache

ENV DEBIAN_FRONTEND="noninteractive"

RUN mkdir -p /usr/share/man/man1 && apt-get update
RUN apt-get install -y libreadline-dev libxpm4 libxpm-dev libjpeg-dev libfreetype6-dev libssl-dev \
       mysql-server mysql-client openjdk-8-jre-headless wget git procps unzip curl \
       ${PHPIZE_DEPS} libmcrypt-dev libpng-dev libc-client-dev libkrb5-dev libzip-dev \
       gnupg1 apt-transport-https sudo python3 python3-pip

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN echo "deb https://download.docker.com/linux/debian stretch stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce
RUN docker-php-ext-configure gd --with-gd --with-jpeg-dir --with-freetype-dir
RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN git clone https://github.com/krakjoe/uopz /tmp/uopz \
    && cd /tmp/uopz && phpize && ./configure && make && make install \
    && docker-php-ext-enable uopz
RUN docker-php-ext-install mysqli pdo_mysql gd zip opcache
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install imap
RUN mkdir /code
RUN apt-get remove -y --purge ${PHPIZE_DEPS}
RUN apt-get autoremove -y
RUN apt-get clean -y
RUN rm -rf /tmp/*
RUN curl -Lso- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; return 0

RUN echo "output_buffering=On\nmemory_limit=-1\nlog_errors=On\nerror_log=/dev/stderr" > /usr/local/etc/php/conf.d/memory.ini

RUN rm -rf /usr/src/* /tmp/*

RUN a2enmod proxy rewrite

WORKDIR /home/swift
ADD vhost.conf /etc/apache2/sites-enabled/000-default.conf

RUN echo "[mysql]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\ndatabase=swift\n\n[mysqladmin]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\n\n[mysqldump]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\n" > ~/.my.cnf

RUN echo 'echo "*** TO INSTALL SWIFT USE ***\n\nphp ./console.setup.php Trilogy \"http%3A%2F%2Fkayako-dev%2F\" Kayako Admin admin admin virlatinus%40gmail.com\n\n"' > ~/.bashrc

RUN useradd -G www-data -u 1000 wgarcia
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
