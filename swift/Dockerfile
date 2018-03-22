# Pull from the ubuntu:latest
FROM ubuntu:latest

# Update cache and install base packages
RUN apt-get update && apt-get -y install \
    software-properties-common \
    python-software-properties \
    debian-archive-keyring \
    wget \
    curl \
    vim \
    aptitude \
    dialog \
    net-tools \
    mcrypt \
    build-essential \
    tcl8.5 \
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
		php5.6-xdebug

# Turn off daemon mode
# Reference: http://stackoverflow.com/questions/18861300/how-to-run-nginx-within-docker-container-without-halting
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# Backup the default configurations
RUN cp /etc/php/5.6/fpm/php.ini /etc/php/5.6/fpm/php.ini.original.bak
RUN mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.original

# Configure PHP settings
RUN perl -pi -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/5.6/fpm/php.ini
RUN perl -pi -e 's/allow_url_fopen = Off/allow_url_fopen = On/g' /etc/php/5.6/fpm/php.ini
RUN perl -pi -e 's/expose_php = On/expose_php = Off/g' /etc/php/5.6/fpm/php.ini

# Copy default site conf
COPY default.conf /etc/nginx/sites-available/default

# Set the current working directory
WORKDIR /var/www/html/classic

# Expose port 80
EXPOSE 80

# Boot up Nginx, and PHP5-FPM when container is started
CMD service php5.6-fpm start && nginx
