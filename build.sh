#!/bin/sh

CONFIG="./swift/kayako-SWIFT/trunk/__swift/config/config.php"
if [ ! -f $CONFIG ]; then
		echo "$CONFIG does not exist!"
		exit 1
fi
GATEWAY=$(docker.exe inspect classic_default -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}' 2>/dev/null)
if [ -z "$GATEWAY" ]; then
		echo "Unable to get IP of MySQL container"
		echo "Remember to set DB_HOSTNAME on $CONFIG"
else
		perl -pi -e "s/(?=('DB_HOSTNAME', ))'.*'/\\1'$GATEWAY'/" $CONFIG
fi

HOSTIP=$(ip -4 address show eth1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [ -z "$HOSTIP" ]; then
		echo "Unable to get host IP address"
		exit 1
fi
echo "XDEBUG_HOST=$HOSTIP" > .env

DIR="./swift/kayako-SWIFT/trunk"
if [ ! -d $DIR ]; then
		echo "$DIR does not exist!"
		exit 1
fi
WINPATH=$(readlink -f $DIR | sed -e 's|^/mnt/c|C:|' -e 's|/|\\|g')
printf "CODE_PATH=%s\n" $WINPATH >> .env

echo "Press ENTER to start composing..."
read key

docker-compose.exe up --build -d
