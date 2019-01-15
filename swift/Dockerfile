FROM php:7.3-apache-debug

ENV DEBIAN_FRONTEND="noninteractive"

RUN mkdir -p /usr/share/man/man1 && apt-get update
RUN apt-get install -y libreadline-dev libxpm4 libxpm-dev libjpeg-dev libfreetype6-dev libssl-dev \
       mysql-server mysql-client openjdk-8-jre-headless wget git procps unzip curl \
       ${PHPIZE_DEPS} libmcrypt-dev libpng-dev libc-client-dev libkrb5-dev libzip-dev \
       gnupg1 apt-transport-https sudo python3 python3-pip

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN echo "deb https://download.docker.com/linux/debian stretch stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce \
       file binutils gdb apache2-dbg
RUN docker-php-ext-configure gd --with-gd --with-jpeg-dir --with-freetype-dir
RUN docker-php-ext-install mysqli pdo_mysql gd zip
#RUN docker-php-ext-install opcache
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install imap

RUN pecl install uopz-beta
RUN pecl install xdebug-beta

RUN curl -Lso- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; return 0

RUN echo "memory_limit=512M\nlog_errors=On\nerror_log=/var/log/php.log" > /usr/local/etc/php/conf.d/memory.ini

RUN a2enmod proxy rewrite

WORKDIR /home/swift/trunk
ADD vhost.conf /etc/apache2/sites-enabled/000-default.conf

RUN echo "[mysql]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\ndatabase=swift\n\n[mysqladmin]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\n\n[mysqldump]\nhost=mysql\nuser=root\npassword=OGYxYmI1OTUzZmM\n" > ~/.my.cnf

RUN echo 'echo "*** TO INSTALL SWIFT USE ***\n\nphp ./console.setup.php Trilogy \"http%3A%2F%2Fkayako-dev%2F\" Kayako Admin admin admin virlatinus%40gmail.com\n\n"' > ~/.bashrc

RUN useradd -G www-data -u 1000 wgarcia
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

# Debugging helpers
RUN mkdir /var/coredumps && touch /var/log/php.log && chown www-data:www-data /var/coredumps /var/log/php.log && chmod 777 /var/coredumps
VOLUME /var/coredumps
RUN echo "CoreDumpDirectory /var/coredumps" >> /etc/apache2/apache2.conf

RUN ln -s /usr/src/php/.gdbinit ~/.gdbinit

## Install internationalization
RUN apt-get install -y icu-devtools libicu-dev
RUN docker-php-ext-install intl

RUN apt-get install -y html2text
RUN mkdir ~/bin; echo "cd /home/swift/trunk/staff; PATH_INFO=/Core/Default/RebuildCache php index.php|html2text" > ~/bin/rebuildcache && chmod +x ~/bin/rebuildcache && echo 'PATH=$PATH:~/bin' >> ~/.bashrc

## Clean up
RUN apt-get remove -y --purge ${PHPIZE_DEPS}
RUN apt-get autoremove -y
RUN apt-get clean -y

## Do not remove php source for debugging symbols
#RUN rm -rf /usr/src/* /tmp/*

# Enable debug extensions: 
RUN docker-php-ext-enable uopz 
RUN docker-php-ext-enable xdebug
