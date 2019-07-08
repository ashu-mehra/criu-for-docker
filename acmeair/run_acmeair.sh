#!/bin/bash

source ./common_env_vars.sh
source ./util.sh

cleanup() {
	echo "INFO: Cleanup - Started"
	echo "INFO: Cleaning running containers"

	cmd="docker stop "${app_container}""
	echo "CMD: ${cmd}"
	${cmd} &> /dev/null

	cmd="docker rm "${app_container}""
	echo "CMD: ${cmd}"
	${cmd} &> /dev/null

	echo "INFO: Cleanup - Done"
}

app_image=$2
app_container=$3

if [ -z "${app_image}" ]; then
	app_image="${APP_DOCKER_IMAGE}"
fi
if [ -z "${app_container}" ]; then
	app_container="${ACMEAIR_CONTAINER}"
fi

# remove existing containers and images if any
cleanup

cmd="docker run --name="${app_container}" "${DOCKER_CAPABILITIES}" "${DOCKER_SECURITY_OPTS}" -d -p 8080:8080 "${app_image}""
echo "CMD: ${cmd}"

acmeair_server=`${cmd}`

if [ $? -ne 0 ]; then
	echo "ERROR: Failed to start acmeair server container"
	exit 1
fi

echo "INFO: Acmeair server container id ${acmeair_server}"
echo "INFO: Starting acmeair server container - Done"

