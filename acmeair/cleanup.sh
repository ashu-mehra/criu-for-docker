#!/bin/bash

app_container=$1

echo "INFO: Cleanup - Started"
echo "INFO: Cleaning running containers"

cmd="docker stop "${app_container}""
echo "CMD: ${cmd}"
${cmd} &> /dev/null

cmd="docker rm "${app_container}""
echo "CMD: ${cmd}"
${cmd} &> /dev/null

echo "INFO: Cleanup - Done"
