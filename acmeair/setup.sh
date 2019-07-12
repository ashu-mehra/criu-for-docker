#!/bin/bash

source ./app_env_vars.sh
source ../util.sh

setup_docker_network() {
	echo "Setting up docker network"
	network=`docker network ls | grep "${DOCKER_NETWORK}"`
	if [ $? -ne 0 ]; then
		docker network create --driver bridge --subnet='172.28.0.0/16' "${DOCKER_NETWORK}" &>/dev/null
		if [ $? -ne 0 ]; then
			echo "ERROR: docker network failed"
			return 1
		else
			return 0
		fi
	fi
}

start_db() {
	check_container_running "${MONGO_DB_IMAGE}" "${MONGO_DB_CONTAINER}"
	if [ $? -eq 1 ]; then
		mongo_db=`docker run --name="${MONGO_DB_CONTAINER}" --network="${DOCKER_NETWORK}" --ip='172.28.0.2' -d "${MONGO_DB_IMAGE}"`
		echo "INFO: Mongo db container id ${mongo_db}"
		return 0
	fi
}

setup_docker_network
if [ $? -ne 0 ]; then
	echo "ERROR: Failed to setup docker network"
	exit 1
fi

start_db
if [ $? -ne 0 ]; then
	echo "ERROR: failed to start mongo db"
	exit 1
fi
