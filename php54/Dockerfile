# Pull from phpenv
FROM vandries/phpenv:5.4

# Disable TERM warning during build
ARG DEBIAN_FRONTEND=noninteractive

# Download Nginx signing key
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 9D6D8F6BC857C906 7638D0442B90D010

# Update cache and install base packages
RUN apt-get update && apt-get -y install apt-utils

RUN apt-get -y install \
    curl \
    vim

RUN echo "set number\nsyntax on" > /.vimrc

RUN curl -Lso- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -LsO http://pear.php.net/install-pear-nozlib.phar && \
    php install-pear-nozlib.phar

RUN phpenv rehash

RUN pecl config-set php_ini $(php-config --prefix)/etc/php.ini && \
    pear config-set php_ini $(php-config --prefix)/etc/php.ini

RUN pecl install xdebug-2.4.1

RUN perl -pi -e "s[xdebug.so][$(php-config --extension-dir)/xdebug.so]" $(php-config --prefix)/etc/php.ini
RUN perl -pi -e "s[;date.timezone =][date.timezone = \"UTC\"]" $(php-config --prefix)/etc/php.ini

# clean up
RUN rm install-pear-nozlib.phar

# Set the current working directory
WORKDIR /home/swift
