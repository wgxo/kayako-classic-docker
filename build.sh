#!/bin/sh

echo "COMPOSE_PROJECT_NAME=classic" > .env

##### Xdebug stuff #####
HOSTIP=$(ip route show scope global|grep -oP '(?<=src\s)\d+(\.\d+){3}')

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
		docker-compose up --build -d
else
		docker-compose up -d
fi
