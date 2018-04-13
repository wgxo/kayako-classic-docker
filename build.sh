#!/bin/sh

echo "COMPOSE_PROJECT_NAME=classic" > .env

CONFIG="./swift/kayako-SWIFT/trunk/__swift/config/config.php"
if [ ! -f $CONFIG ]; then
		echo "$CONFIG does not exist!"
		exit 1
fi

perl -pi -e "s/(?=('DB_HOSTNAME', ))'.*'/\\1'mysql'/" $CONFIG

HOSTIP=$(ip route show scope global|grep -oP '(?<=src\s)\d+(\.\d+){3}')
if [ -z "$HOSTIP" ]; then
		echo "Unable to get host IP address"
		exit 1
fi
echo "XDEBUG_HOST=$HOSTIP" >> .env

DIR="./swift/kayako-SWIFT/trunk"
if [ ! -d $DIR ]; then
		echo "$DIR does not exist!"
		exit 1
fi
DEST=$(readlink -f $DIR)
printf "CODE_PATH=%s\n" $DEST >> .env

for d in ../vendor/*; do
		APP=$(basename $d | sed 's/-.*$//' | awk '{print toupper($0)}' )
		DEST=$(readlink -f $d)
		printf "%s=%s\n" $APP $DEST >> .env
done

if [ $# -gt 0 ]; then
		docker-compose up --build -d
else
		docker-compose up -d
fi
