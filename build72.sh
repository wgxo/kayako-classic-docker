#!/bin/sh

# stop mysql docker container
docker ps|grep swift_mysql && (docker ps|grep swift_mysql | awk '{print $1}'|xargs docker stop)

DIR="./swift/kayako-SWIFT/trunk"

# COLORS
LIGHT_GRAY="\033[0;37m"; BLUE="\033[1;36m"; RED="\033[0;31m"; LIGHT_RED="\033[1;31m";
GREEN="\033[1;32m"; WHITE="\033[1;37m"; LIGHT_GRAY="\033[0;37m"; YELLOW="\033[1;33m";
NOCOLOR="\033[0m"

MYSQL_SERVER="aladdin_db_1"
MYSQL_PASS="OGYxYmI1OTUzZmM"

# start mysql if is not running
(docker ps | grep -q $MYSQL_SERVER) || (cd ~/kayako/aladdin; docker-compose up -d db)

# PHPStorm development machine MAC address
MAC="00:0c:29:58:25:aa"

LINES=`tput lines`
COLS=`tput cols`

echo "COMPOSE_PROJECT_NAME=classic" > .env
echo "LINES=$LINES" >> .env
echo "COLS=$COLS" >> .env

##### MySQL Stuff #####
perl -pi -e "s/(?=('DB_HOSTNAME', ))'.*'/\\1'$MYSQL_SERVER'/" \
        ./swift/kayako-SWIFT/trunk/__swift/config/config.php
perl -pi -e "s/(?=('DB_PASSWORD', ))'.*'/\\1'$MYSQL_PASS'/" \
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
HOSTIP=$(arp -na |grep $MAC|grep -oP '\d+(\.\d+){3}')

if [ -z "$HOSTIP" ]; then
		echo "Unable to get host IP address"
		exit 1
fi

echo "XDEBUG_HOST=$HOSTIP" >> .env


##### Swift stuff #####

if [ ! -d $DIR ]; then
		echo "$DIR does not exist!"
		exit 1
fi

DEST=$(readlink -f $DIR)

printf "CODE_PATH=%s\n" $DEST >> .env


##### Vendor stuff #####
for d in ../vendor/*; do
		APP=$(basename $d | sed 's/-.*$//' | awk '{print toupper($0)}' )
		DEST=$(readlink -f $d)
		printf "%s=%s\n" $APP $DEST >> .env
done


##### Build it! #####
if [ $# -gt 0 ]; then
		if [ "$1" = "f" ]; then
				docker-compose build --no-cache swift72
				docker-compose up -d swift72
		else
				docker-compose up --build -d swift72
		fi
else
		docker-compose up -d swift72
fi

echo "$GREEN*** Remember to check your database settings in $DIR/__swift/config/config.php ***$NOCOLOR"
grep "DB_" $DIR/__swift/config/config.php|head -4
grep "^define.*DEBUG" $DIR/__swift/config/config.php
grep "^define.*ENVIRON" $DIR/__swift/config/config.php

