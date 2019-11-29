#!/bin/bash

source ../common_env_vars.sh

app_image=$2
app_container=$3

./start_daytrader7.sh "${app_image}" "${app_container}" "9082"

if [ $? -ne 0 ]; then
       echo "ERROR: error in starting up daytrader server container"
       exit 1
fi

