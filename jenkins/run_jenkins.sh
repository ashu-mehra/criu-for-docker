#!/bin/bash

source ./common_env_vars.sh

app_image=$2
app_container=$3

cmd="docker run --name="${app_container}" "${DOCKER_CAPABILITIES}" "${DOCKER_SECURITY_OPTS}" -d -p 8080:8080 -p 50000:50000 -v jenkins-data:/var/jenkins_home -v /root/.ssh:/root/.ssh "${app_image}""
echo "CMD: ${cmd}"

jenkins_server=`${cmd}`

if [ $? -ne 0 ]; then
       echo "ERROR: Failed to start jenkins server container"
       exit 1
fi

echo "INFO: Jenkins server container id ${jenkins_server}"
