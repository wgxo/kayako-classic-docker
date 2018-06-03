#!/bin/sh

MYSQL_SERVER="aladdin_db_1"
MYSQL_PASS="OGYxYmI1OTUzZmM"
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
GWIP=$(ip route show scope global|grep -oP '(?<=src\s)\d+(\.\d+){3}')

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
HOSTIP=$(arp -na |grep 00:0c:29:58:25:aa|grep -oP '\d+(\.\d+){3}')

if [ -z "$HOSTIP" ]; then
		echo "Unable to get host IP address"
		exit 1
fi

echo "XDEBUG_HOST=$HOSTIP" >> .env


##### Swift stuff #####
DIR="./swift/kayako-SWIFT/trunk"

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
				docker-compose build --no-cache
				docker-compose up -d
		else
				docker-compose up --build -d
		fi
else
		docker-compose up -d
fi

echo "*** Remember to check your database settings in SWIFT_DIR/__swift/config/config.ini ***"
