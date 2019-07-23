#!/bin/sh

DIR="./swift/kayako-SWIFT"

# COLORS
LIGHT_GRAY="\033[0;37m"; BLUE="\033[1;36m"; RED="\033[0;31m"; LIGHT_RED="\033[1;31m";
GREEN="\033[1;32m"; WHITE="\033[1;37m"; LIGHT_GRAY="\033[0;37m"; YELLOW="\033[1;33m";
NOCOLOR="\033[0m"

MYSQL_SERVER="mysql"
MYSQL_PASS="OGYxYmI1OTUzZmM"

# PHPStorm development machine MAC address
MAC="00:0c:29:58:25:aa"

LINES=`tput lines`
COLS=`tput cols`

echo "COMPOSE_PROJECT_NAME=classic" > .env
echo "LINES=$LINES" >> .env
echo "COLS=$COLS" >> .env
echo "USER=$USER" >> .env

##### MySQL Stuff #####
perl -pi -e "s/(?=('DB_HOSTNAME', ))'.*'/\\1'$MYSQL_SERVER'/" \
        ./swift/kayako-SWIFT/trunk/__swift/config/config.php
perl -pi -e "s/(?=('DB_PASSWORD', ))'.*'/\\1'$MYSQL_PASS'/" \
        ./swift/kayako-SWIFT/trunk/__swift/config/config.php

perl -pi -e "s/(?=('SWIFT_DEBUG', ))'.*'/\\1 true/" \
        ./swift/kayako-SWIFT/trunk/__swift/config/config.php

##### Gateway stuff #####
# I need to get the IP of the machine running docker, so it can be accessed internally by swift
DEV=$(ip route show scope global|grep -Poe '(?<=dev )\w+')
GWIP=$(ip addr show dev $DEV|grep -oP '(?<=inet\s)\d+(\.\d+){3}')

if [ -z "$GWIP" ]; then
		echo "Unable to get GW IP address"
		exit 1
fi

echo "GWIP=$GWIP" >> .env

##### Xdebug stuff #####
# I need to get the IP of my Windows development machine where PHPStorm is installed.
# I need the IP so KC inside the Docker container can establish a connection.
# Since the network uses DHCP to get IPs, I only know the MAC address and I use the following
# code to get the dynamic IP
HOSTIP=$(arp -na |grep $MAC|grep -oP '\d+(\.\d+){3}'|head -1)

if [ -z "$HOSTIP" ]; then
		echo "Unable to get host IP address"
		exit 1
fi

echo "XDEBUG_CONFIG=idekey=PHPSTORM remote_host=$HOSTIP remote_enable=1 remote_autostart=1" >> .env


##### Build it! #####
if [ $# -gt 0 ]; then
		if [ "$1" = "f" ]; then
				docker-compose build --no-cache swift
				docker-compose up -d swift
		else
				docker-compose up --build -d swift
		fi
else
		docker-compose up -d swift
fi

echo "$GREEN*** Remember to check your database settings in $DIR/trunk/__swift/config/config.php ***$NOCOLOR"
grep "DB_" $DIR/trunk/__swift/config/config.php|head -4
grep "^define.*DEBUG" $DIR/trunk/__swift/config/config.php
grep "^define.*ENVIRON" $DIR/trunk/__swift/config/config.php

