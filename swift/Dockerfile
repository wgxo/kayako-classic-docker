# Pull from the ubuntu:latest
FROM ubuntu:latest

# Disable TERM warning during build
ARG DEBIAN_FRONTEND=noninteractive

# Update cache and install base packages
RUN apt-get update && apt-get -y install \
    software-properties-common \
    python-software-properties \
    debian-archive-keyring \
		apt-utils \
		libterm-readline-perl-perl \
    wget \
    curl \
    vim \
    aptitude \
    dialog \
    net-tools \
    mcrypt \
    build-essential \
    tcl8.5 \
		zip \
		unzip \
    git

# Download Nginx signing key
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com C300EE8C

# Add to repository sources list
RUN add-apt-repository ppa:nginx/stable
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php

# Update cache and install Nginx
RUN apt-get update && apt-get -y install nginx php5.6

# Install PHP modules
RUN apt-get install -y \
    php5.6-fpm \
    php5.6-cli \
    php5.6-mysql \
    php5.6-mysqli \
    php5.6-mbstring \
    php5.6-curl \
    php5.6-mcrypt \
    php5.6-gd \
    php5.6-xml \
    php5.6-zip \
    php5.6-intl \
    php5.6-imap \
    php5.6-sqlite3 \
		php5.6-xdebug

# Install PEAR
RUN apt-get install -y php-pear

# Turn off daemon mode
# Reference: http://stackoverflow.com/questions/18861300/how-to-run-nginx-within-docker-container-without-halting
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# Backup the default configurations
RUN cp /etc/php/5.6/fpm/php.ini /etc/php/5.6/fpm/php.ini.original.bak
RUN mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.original

# Configure PHP settings
RUN perl -pi -e 's/;(?=cgi.fix_pathinfo=1)//g' /etc/php/5.6/fpm/php.ini
RUN perl -pi -e 's/;(?=always_populate_raw_post_data = -1)//g' /etc/php/5.6/fpm/php.ini
RUN perl -pi -e 's/(?=allow_url_fopen = )Off/On/g' /etc/php/5.6/fpm/php.ini
RUN perl -pi -e 's/(?=expose_php = )On/Off/g' /etc/php/5.6/fpm/php.ini
RUN perl -pi -e 's/(?=upload_max_filesize = )2M/25M/g' /etc/php/5.6/fpm/php.ini
RUN perl -pi -e 's/(?=max_execution_time = )30/300/g' /etc/php/5.6/fpm/php.ini

# install composer
RUN curl -Lso- https://getcomposer.org/installer|php -- --install-dir=/usr/local/bin --filename=composer

ARG xdebug_host
RUN echo  "\n[xdebug]\nxdebug.idekey=PHPSTORM\nxdebug.remote_host=$xdebug_host\nxdebug.remote_port=9001\nxdebug.remote_enable=1" >> /etc/php/5.6/mods-available/xdebug.ini

# Copy default site conf
COPY server.conf /etc/nginx/nginx.conf
COPY site.conf /etc/nginx/sites-available/default

RUN chown -R www-data:www-data /var/www

# Set the current working directory
WORKDIR /var/www

# Expose port 80
EXPOSE 80

# Replace index file
RUN mv html/index.nginx-debian.html html/index.html

RUN apt-get install -y sudo
RUN echo "www-data ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Boot up Nginx, and PHP5-FPM when container is started
CMD service php5.6-fpm start && nginx
