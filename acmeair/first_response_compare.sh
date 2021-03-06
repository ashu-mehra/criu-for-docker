#!/bin/bash

source ../common_env_vars.sh
source ./app_env_vars.sh

check_server_started() {
        local retry_counter=0
	container_name=$1
        while true;
        do
		docker exec "${container_name}" grep "${LOG_MESSAGE}" "${LOG_LOCATION}" &> /dev/null
                local app_started=$?
                if [ ${app_started} -eq 0 ]; then
                        break
                else
                        sleep 1s
                fi
        done
}

test_acmeair_su() {
	isColdRun=$1
	echo "Starting acmeair using original image for startup measurement"
	start_time=`date +"%s.%3N"`
	./start_acmeair.sh "${APP_DOCKER_IMAGE}" "acmeair-base-su" "9082" &
	sleep 3s
	echo "Waiting..."
	check_server_started "acmeair-base-su"
	if [ $? -eq 0 ]; then
		startupMsg=`docker exec acmeair-base-su grep "${LOG_MESSAGE}" "${LOG_LOCATION}"`
		end_time=`perl getLibertyStartTime.pl "$startupMsg"`
	fi
	diff=`echo "$end_time-$start_time" | bc`
	echo "Start time: ${start_time}"
	echo "End time: ${end_time}"
	echo "Response time: ${diff} seconds"
	if [ $1 -eq 0 ]; then
		acmeair_su+=(${diff})
	else
		echo "Ignoring this as cold run"
	fi
	echo -n "Stopping the container ... "
	docker stop acmeair-base-su &>/dev/null 
	docker rm acmeair-base-su &>/dev/null 
	sleep 5s
	echo "Done"
}

test_acmeair_fr() {
	isColdRun=$1
	echo "Starting acmeair using original image"
	start_time=`date +"%s.%3N"`
	./start_acmeair.sh "${APP_DOCKER_IMAGE}" "acmeair-base" "9082" &
	sleep 1s
	echo "Waiting ..."
	while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:9082/flights.html)" != "200" ]]; do 
		sleep .00001;
	done
	end_time=`date +"%s.%3N"`
	diff=`echo "$end_time-$start_time" | bc`
	echo "Start time: ${start_time}"
	echo "End time: ${end_time}"
	echo "Response time: ${diff} seconds"
	if [ $1 -eq 0 ]; then
		acmeair_fr+=(${diff})
	else
		echo "Ignoring this as cold run"
	fi
	echo -n "Stopping the container ... "
	docker stop acmeair-base &>/dev/null 
	docker rm acmeair-base &>/dev/null 
	sleep 5s
	echo "Done"
}

test_acmeair_fr_criu() {
	isColdRun=$1
	echo "Starting acmeair using checkpoint"
	start_time=`date +"%s.%3N"`
	./start_acmeair.sh "${APP_CR_DOCKER_IMAGE}" "acmeair-criu" "9084" &
	sleep .01
	echo "Waiting ..."
	while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:9084/flights.html)" != "200" ]]; do sleep .00001; done
	end_time=`date +"%s.%3N"`
	diff=`echo "$end_time-$start_time" | bc`
	echo "Start time: ${start_time}"
	echo "End time: ${end_time}"
	echo "Response time: ${diff} seconds"
	if [ $1 -eq 0 ]; then
		acmeair_fr_criu+=(${diff})
	else
		echo "Ignoring this as cold run"
	fi

        onEntry=`docker logs acmeair-criu | grep "onEntry" | cut -d ':' -f 2`
        afterRemount=`docker logs acmeair-criu | grep "after mounting" | cut -d ':' -f 2`
        beforeRestore=`docker logs acmeair-criu | grep "before restore" | cut -d ':' -f 2`
        diff=`echo "${afterRemount}-${onEntry}" | bc`
        echo "time to remount proc: ${diff}"
        diff=`echo "${beforeRestore}-${onEntry}" | bc`
        echo "time taken before restoring: ${diff}"
        restore_time=`docker exec acmeair-criu crit show stats-restore | grep restore_time | cut -d ':' -f 2 | cut -d ',' -f 1`
        echo "time to restore: " $((${restore_time}/1000))

	echo -n "Stopping the container ... "
	docker stop acmeair-criu &> /dev/null 
	docker rm acmeair-criu &> /dev/null 
	sleep 15s
	echo "Done"
}

cleanup() {
	docker stop mongodb
	docker container prune -f &> /dev/null &
}

get_average() {
	arr=("$@")
	# echo "values: ${arr[@]}"
	sum=0
	for val in ${arr[@]}
	do
		sum=`echo "${sum}+${val}" | bc`
	done
	echo "scale=3; $sum/${#arr[@]}" | bc
}

get_averages() {
	for key in ${headers[@]}
	do
		value_list=(${values[$key]})
		#echo "value_list: ${value_list[@]}"
		#get_average ${value_list[@]}
		averages[$key]=$(get_average ${value_list[@]})
	done
}

print_summary() {
	echo "########## Summary ##########"
	printf "\t"
	for key in ${headers[@]}
	do
		printf "%-15s" "${key}"
	done
	echo
	index=0
	for batch in `seq 1 ${batches}`;
	do
		for itr in `seq 1 ${iterations}`;
		do
			printf "${batch}.${itr}\t"
			for key in ${headers[@]};
			do
				value_list=(${values[$key]})
				printf "%-15s" "${value_list[${index}]}"
			done
			echo
			index=$(( $index + 1 ))
		done
	done
	printf "Avg\t"
	for key in ${headers[@]}
	do
		printf "%-15s" "${averages[$key]}"
	done
	echo
}

declare -a headers=("acmeair_su" "acmeair_fr" "acmeair_fr_criu")

declare -A values
declare -A averages
for key in ${headers[@]}
do
	averages[$key]=0
done

declare -a acmeair_su acmeair_fr acmeair_fr_criu

if [ $# -lt 2 ]; then
	echo "Invalid number of arguments; please pass number of batches and iterations\n"
	exit -1	
fi

./run_mongo.sh

batches=$1
iterations=$2
for batch in `seq 1 ${batches}`;
do
	for key in ${headers[@]}
	do
		echo "Cold run for batch ${batch}"
		test_${key} 1
		for itr in `seq 1 ${iterations}`;
		do
			echo "###"
			echo "Iteration ${batch}.${itr} for ${key}"
			test_${key} 0
		done
	done
done

cleanup

values["acmeair_su"]=${acmeair_su[@]}
values["acmeair_fr"]=${acmeair_fr[@]}
values["acmeair_fr_criu"]=${acmeair_fr_criu[@]}

get_averages
print_summary
