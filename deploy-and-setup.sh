#!/bin/sh

WORKSPACE="./swift/kayako-SWIFT"

[ -d ${WORKSPACE}/trunk ] || git clone git@github.com:trilogy-group/kayako-SWIFT ${WORKSPACE}

sh build.sh

docker-compose exec swift bash -c "composer install"

sudo rm -rf "${WORKSPACE}/trunk/__swift/logs" "${WORKSPACE}/trunk/__swift/cache" "${WORKSPACE}/trunk/__swift/files"
sudo mkdir "${WORKSPACE}/trunk/__swift/logs" "${WORKSPACE}/trunk/__swift/cache" "${WORKSPACE}/trunk/__swift/files"
sudo chmod 777 -R "${WORKSPACE}/trunk/__swift/logs" "${WORKSPACE}/trunk/__swift/cache" "${WORKSPACE}/trunk/__swift/files"

[ -d ${WORKSPACE}/trunk/setup.bak ] || docker-compose exec swift bash -c "mysqladmin drop -f swift; mysqladmin create swift; cd setup; php console.setup.php Trilogy "http%3A%2F%2Ffaster.xo.local%2F" Kayako Admin admin admin werner.garcia%2Bkcadmin%40crossover.com; cd ..; [ -f __swift/cache/SWIFT_Loader.cache ] && mv setup setup.bak"
