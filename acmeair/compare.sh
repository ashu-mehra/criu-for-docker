#!/bin/bash

source ../common_env_vars.sh
source ./app_env_vars.sh

echo "Starting acmeair using original image"
./start_acmeair.sh "${APP_DOCKER_IMAGE}" "acmeair-base" "8080" "172.28.0.4" &

echo "Starting acmeair using checkpoint"
./start_acmeair.sh "${APP_CR_DOCKER_IMAGE}" "acmeair-criu" "8090" "172.28.0.3" &

sleep 25s

docker stop acmeair-base &> /dev/null 
docker stop acmeair-criu &> /dev/null 

docker container prune -f &> /dev/null &
