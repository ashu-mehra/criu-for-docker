#!/bin/bash

source ./util.sh
source ./common_env_vars.sh

app=$1

if [ -z "${app}" ]; then
	echo "ERROR: app name is required"
	exit 1;
fi
if [ ! -d "${app}" ]; then
	echo "ERROR: directory with app name is not present"
	exit 1;
fi

# check required files are present
if [ ! -f ${app}/run_${app}.sh ]; then
	echo "ERROR: ${app}/run_${app}.sh is missing"
	exit 1;
fi
if [ ! -f ${app}/run_app.sh ]; then
	echo "ERROR: ${app}/run_app.sh is missing"
	exit 1;
fi
if [ ! -f ${app}/app_env_vars.sh ]; then
	echo "ERROR: ${app}/app_env_vars.sh is missing"
	exit 1;
fi

source ./${app}/app_env_vars.sh

tmp_image_name="${APP_DOCKER_IMAGE}-tmp"
container_name="app-container-for-cr"

build_docker_image() {
	if [ -z "${DOCKER_IMAGE_OS}" ]; then
		DOCKER_IMAGE_OS=ubuntu
	fi
	cp Dockerfile.${DOCKER_IMAGE_OS} ./${app}
	sed -i -e "s|<app image>|$APP_DOCKER_IMAGE|" ./${app}/Dockerfile.${DOCKER_IMAGE_OS}
	echo "Building temporary docker image ... "
	cmd="docker build --build-arg user=${CONTAINER_USER} --build-arg app=${app} -q -t "${tmp_image_name}" -f ./${app}/Dockerfile.${DOCKER_IMAGE_OS} ."
	echo "CMD: ${cmd}"
	${cmd} &>/dev/null
	echo "Done"

	check_image_exists "${tmp_image_name}"
	if [ $? -eq 1 ]; then
		echo "ERROR: Building temporary image failed"
		exit 1
	fi
}

run_container() {
	pushd ${app} &>/dev/null
	./run_${app}.sh "${app}" "${tmp_image_name}" "${container_name}"
	popd &>/dev/null

	check_container_running "${tmp_image_name}" "${container_name}"
	if [ $? -eq 1 ]; then
		echo "ERROR: Did not find container "${container_name}""
		exit 1
	fi
}

check_server_started() {
        local retry_counter=0
        while true;
        do
                echo "INFO: Checking if application started (retry counter=${retry_counter})"
		if [ "${LOG_LOCATION}" = "stdout" ];then
			docker logs "${container_name}" 2>&1 | grep "${LOG_MESSAGE}" &> /dev/null
		else
			docker exec "${container_name}" grep "${LOG_MESSAGE}" "${LOG_LOCATION}" &> /dev/null
		fi
                local app_started=$?
                if [ ${app_started} -eq 0 ]; then
                        echo "INFO: Application started successfully!"
			break
                else
                        if [ $retry_counter -eq ${TIMEOUT} ]; then
                                echo "ERROR: Application did not start properly"
                                exit 1
                        fi
                        retry_counter=$(($retry_counter+1))
                        sleep 1s
                fi
        done
}

get_app_pid() {
	echo `docker exec "${container_name}" ps -ef | grep java | grep -v grep | awk '{ print $2 }'`
}

create_checkpoint() {
	check_server_started
	if [ $? -eq 0 ]; then
		app_pid=$(get_app_pid)
		echo "INFO: App pid in container is ${app_pid}"
		if [ "${CONTAINER_USER}" = "root" ]; then
			cmd="criu dump -t "${app_pid}" --tcp-established -j -v4 -o "${CR_LOG_DIR}/${DUMP_LOG_FILE}""
		else
			cmd="sudo criu dump -t "${app_pid}" --tcp-established -j -v4 -o "${CR_LOG_DIR}/${DUMP_LOG_FILE}""
		fi
		echo "CMD (container): ${cmd}"
		docker exec --privileged "${container_name}" bash -c "${cmd}"
		if [ "${CONTAINER_USER}" = "root" ]; then
			docker exec "${container_name}" bash -c "chmod 755 "${CR_LOG_DIR}/${DUMP_LOG_FILE}""
		else
			docker exec "${container_name}" bash -c "sudo chmod 755 "${CR_LOG_DIR}/${DUMP_LOG_FILE}""
		fi
	fi
}

commit_container() {
	cmd="docker cp "${container_name}":"${CR_LOG_DIR}"/"${DUMP_LOG_FILE}" ."
	echo "CMD: ${cmd}"
	${cmd}

	cmd="docker commit "${container_name}" "${APP_CR_DOCKER_IMAGE}""
	echo "CMD: ${cmd}"
	${cmd}

	echo "INFO: New docker image "${APP_CR_DOCKER_IMAGE}" containing application checkpoint created"

	echo "INFO: Stopping the container"

	cmd="docker stop "${container_name}""
	echo "CMD: ${cmd}"
	${cmd} &> /dev/null

	#cmd="docker rm "${container_name}""
	#echo "CMD: ${cmd}"
	#${cmd} &> /dev/null
}

build_docker_image
run_container
create_checkpoint
commit_container

