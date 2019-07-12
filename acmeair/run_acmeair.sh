#!/bin/bash

source ./app_env_vars.sh

app=$1
app_image=$2
app_container=$3

if [ -z "${app_image}" ]; then
	app_image="${APP_DOCKER_IMAGE}"
fi
if [ -z "${app_container}" ]; then
	app_container="${ACMEAIR_CONTAINER}"
fi

./cleanup.sh "${app_container}"
./setup.sh
if [ $? -ne 0 ]; then
	echo "ERROR: error in setting up acmeair"
	exit 1
fi

./start_acmeair.sh "${app_image}" "${app_container}" "8080" "172.28.0.3"
if [ $? -ne 0 ]; then
	echo "ERROR: error in starting up acmeair"
	exit 1
fi
