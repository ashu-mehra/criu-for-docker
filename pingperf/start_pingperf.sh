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
        app_container="${DAYTRADER7_CONTAINER}"
fi
if [ -z "${host_port}" ]; then
        host_port=8080
fi

cmd="docker run --cpuset-cpus=0,1,32,33 --cpuset-mems=0 --name="${app_container}" "${DOCKER_CAPABILITIES}" "${DOCKER_SECURITY_OPTS}" -d -p ${host_port}:9080 "${app_image}""
echo "CMD: ${cmd}"

pingperf_server=`${cmd}`

if [ $? -ne 0 ]; then
       echo "ERROR: Failed to start pingperf server container"
       exit 1
fi

echo "INFO: Daytrader server container id ${pingperf_server}"
echo "INFO: Starting pingperf server container - Done"
