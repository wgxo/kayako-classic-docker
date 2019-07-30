#!/bin/bash

WORKSPACE="./swift/kayako-SWIFT"

#####################################################
### REPLACE YOUR EMAIL ADDRESS, WEBHOST AND GITHUB SSH KEY BELOW: ###
#####################################################
EMAIL="werner.garcia+kcadmin@crossover.com"
# This is the host of the URL to access Kayako from a web browser: http://faster.xo.local/
WEBHOST="ip-10-66-20-35.ec2.internal"
SSHKEY="~/.ssh/wgxo"

[ -f `readlink -f ${SSHKEY}` ] || { echo "Github SSH key '${SSHKEY}' not found!" ; exit 1; }

[ -d ${WORKSPACE}/trunk ] || ssh-agent bash -c "ssh-add ${SSHKEY}; git clone git@github.com:trilogy-group/kayako-SWIFT.git ${WORKSPACE}"

[ -d ${WORKSPACE}/trunk ] || { echo "Unable to clone repository!" ; exit 1; }

sh build.sh 1

docker-compose exec swift bash -c "XDEBUG_CONFIG=0 composer install"

sudo rm -rf "${WORKSPACE}/trunk/__swift/logs" "${WORKSPACE}/trunk/__swift/cache" "${WORKSPACE}/trunk/__swift/files"
mkdir "${WORKSPACE}/trunk/__swift/logs" "${WORKSPACE}/trunk/__swift/cache" "${WORKSPACE}/trunk/__swift/files"
chmod 777 -R "${WORKSPACE}/trunk/__swift/logs" "${WORKSPACE}/trunk/__swift/cache" "${WORKSPACE}/trunk/__swift/files"
sudo chgrp -R www-data "${WORKSPACE}/trunk/__swift/logs" "${WORKSPACE}/trunk/__swift/cache" "${WORKSPACE}/trunk/__swift/files"
sudo chmod -R g+s "${WORKSPACE}/trunk/__swift/logs" "${WORKSPACE}/trunk/__swift/cache" "${WORKSPACE}/trunk/__swift/files"

# URLEncode variables
EMAIL=`echo ${EMAIL} | perl -lpe 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg'`
WEBHOST=`echo ${WEBHOST} | perl -lpe 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg'`

[ $# -gt 0 -a "$1" = "-f" ] && mv ${WORKSPACE}/trunk/setup.bak ${WORKSPACE}/trunk/setup >/dev/null 2>&1

DBNAME=$(grep -Poe '(?<=MYSQL_DATABASE=").+(?=")' build.sh)

[ -d ${WORKSPACE}/trunk/setup.bak ] || docker-compose exec swift bash -c "mysqladmin drop -f ${DBNAME}; mysqladmin create ${DBNAME}; su - ${USER} -c \"umask 002; cd setup;XDEBUG_CONFIG=0 php console.setup.php Trilogy http%3A%2F%2F${WEBHOST}%2F Kayako Admin admin admin ${EMAIL}; mv ~/setup ~/setup.bak\""
