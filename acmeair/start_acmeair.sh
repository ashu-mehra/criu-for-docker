#!/bin/bash

source ../common_env_vars.sh
source ./app_env_vars.sh

app_image=$1
app_container=$2
host_port=$3

if [ -z "${app_image}" ]; then
	app_image="${APP_DOCKER_IMAGE}"
fi
if [ -z "${app_container}" ]; then
	app_container="${ACMEAIR_CONTAINER}"
fi
if [ -z "${host_port}" ]; then
	host_port=8080
fi

cmd="docker run --rm --cpuset-cpus=0,1,32,33 --cpuset-mems=0 --name="${app_container}" "${DOCKER_CAPABILITIES}" "${DOCKER_SECURITY_OPTS}" -d -p ${host_port}:9090 "${app_image}""
echo "CMD: ${cmd}"

acmeair_server=`${cmd}`

if [ $? -ne 0 ]; then
	echo "ERROR: Failed to start acmeair server container"
	exit 1
fi

echo "INFO: Acmeair server container id ${acmeair_server}"
echo "INFO: Starting acmeair server container - Done"

