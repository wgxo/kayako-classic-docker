#!/bin/sh

HOSTIP=$(docker.exe inspect classic_default -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}')
perl -pi -e "s/(?=('DB_HOSTNAME', ))'.*'/\\1'$HOSTIP'/" swift/kayako-SWIFT/trunk/__swift/config/config.php

docker-compose.exe up --build -d

