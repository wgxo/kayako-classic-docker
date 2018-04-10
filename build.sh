#!/bin/sh

echo "COMPOSE_PROJECT_NAME=classic" > .env

CONFIG="./swift/kayako-SWIFT/trunk/__swift/config/config.php"
if [ ! -f $CONFIG ]; then
		echo "$CONFIG does not exist!"
		exit 1
fi
GATEWAY=$(docker inspect aladdin_default -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}' 2>/dev/null)
if [ -z "$GATEWAY" ]; then
		echo "Unable to get IP of MySQL container"
		echo "Remember to set DB_HOSTNAME on $CONFIG"
else
echo "MYSQL_HOST=$GATEWAY" >> .env
		perl -pi -e "s/(?=('DB_HOSTNAME', ))'.*'/\\1'$GATEWAY'/" $CONFIG
fi

HOSTIP=$(ip -4 address show ens33 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
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

docker-compose up --build -d
