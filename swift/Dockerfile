FROM php:7.2-apache

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install build-essential apt-utils autoconf libreadline-dev ${PHPIZE_DEPS} \
    libxpm4 libxpm-dev libjpeg-dev libfreetype6-dev libc-client-dev libssl-dev

RUN apt install -y libc-client-dev libkrb5-dev && rm -r /var/lib/apt/lists/*

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

RUN docker-php-ext-configure gd --with-gd --with-jpeg-dir --with-freetype-dir \
    && docker-php-ext-install gd
                                  
RUN mkdir -p /usr/share/man/man1 && apt-get update \
    && apt install -y mysql-client wget git procps unzip curl \
                      libmcrypt-dev libpng-dev

RUN pecl install xdebug && docker-php-ext-enable xdebug \
    && pecl install uopz && docker-php-ext-enable uopz \
    && pecl install mcrypt-1.0.1 && docker-php-ext-enable mcrypt \
    && docker-php-ext-install mysqli pdo_mysql zip opcache
		
RUN apt-get remove -y --purge ${PHPIZE_DEPS} \
    && apt-get autoremove -y \
    && apt-get clean -y

RUN curl -Lso- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; return 0

RUN echo "memory_limit=-1\nlog_errors=On\nerror_log=/dev/stderr" > /usr/local/etc/php/conf.d/memory.ini

RUN rm -rf /usr/src/* /tmp/*

RUN a2enmod proxy rewrite

WORKDIR /home/swift
ADD vhost.conf /etc/apache2/sites-enabled/000-default.conf

RUN echo "[mysql]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\ndatabase=swift\n\n[mysqladmin]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\n\n[mysqldump]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\n" > ~/.my.cnf

RUN echo 'echo "*** TO INSTALL SWIFT USE ***\n\nphp ./console.setup.php Trilogy \"http%3A%2F%2Fkayako-dev%2F\" Kayako Admin admin admin virlatinus%40gmail.com\n\n"' > ~/.bashrc

RUN useradd -G www-data -u 1000 wgarcia
