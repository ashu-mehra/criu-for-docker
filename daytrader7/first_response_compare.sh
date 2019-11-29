#!/bin/bash

source ../common_env_vars.sh
source ./app_env_vars.sh

echo "Starting daytrader7 using original image"
start_time=`date +"%s.%3N"`
./start_daytrader7.sh "${APP_DOCKER_IMAGE}" "daytrader7-base" "9082" &
sleep 1s
echo "Waiting ..."
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:9082/daytrader/index.faces)" != "200" ]]; do 
	sleep .00001;
done
end_time=`date +"%s.%3N"`
diff=`echo "$end_time-$start_time" | bc`
echo "Start time: ${start_time}"
echo "End time: ${end_time}"
echo "Response time: ${diff} seconds"
echo -n "Stopping the container ... "
docker stop daytrader7-base &>/dev/null 
sleep 15s
echo "Done"

echo
echo "Starting daytrader7using checkpoint"
start_time=`date +"%s.%3N"`
./start_daytrader7.sh "${APP_CR_DOCKER_IMAGE}" "daytrader7-criu" "9084" &
sleep .01
echo "Waiting ..."
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:9084/daytrader/index.faces)" != "200" ]]; do sleep .00001; done
end_time=`date +"%s.%3N"`
diff=`echo "$end_time-$start_time" | bc`
echo "Start time: ${start_time}"
echo "End time: ${end_time}"
echo "Response time: ${diff} seconds"
echo -n "Stopping the container ... "
docker stop daytrader7-criu &> /dev/null 
sleep 15s
echo "Done"

docker container prune -f &> /dev/null &
