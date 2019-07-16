#!/bin/bash

source ../common_env_vars.sh
source ./app_env_vars.sh

echo "Starting acmeair using original image"
start_time=`date +"%s.%3N"`
./start_acmeair.sh "${APP_DOCKER_IMAGE}" "acmeair-base" "8080" "172.28.0.4" &
echo "Waiting ..."
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:8080/flights.html)" != "200" ]]; do 
	sleep .00001;
done
end_time=`date +"%s.%3N"`
diff=`echo "$end_time-$start_time" | bc`
echo "Response time: ${diff} seconds"
echo -n "Stopping the container ... "
docker stop acmeair-base &>/dev/null 
echo "Done"

sleep 5s
echo
echo "Starting acmeair using checkpoint"
start_time=`date +"%s.%3N"`
./start_acmeair.sh "${APP_CR_DOCKER_IMAGE}" "acmeair-criu" "8080" "172.28.0.3" &
echo "Waiting ..."
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:8080/flights.html)" != "200" ]]; do sleep .00001; done
end_time=`date +"%s.%3N"`
diff=`echo "$end_time-$start_time" | bc`
echo "Response time: ${diff} seconds"
echo -n "Stopping the container ... "
docker stop acmeair-criu &> /dev/null 
echo "Done"

docker container prune -f &> /dev/null &
