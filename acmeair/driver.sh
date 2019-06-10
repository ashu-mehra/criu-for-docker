#!/bin/bash

source ./util.sh
source ./common_env_vars.sh

tmp_image_name="${APP_DOCKER_IMAGE}-tmp"
container_name="app-container-for-cr"

build_docker_image() {
	sed -i -e "s|<app image>|$APP_DOCKER_IMAGE|" Dockerfile
	cmd="docker build --build-arg user=1001 -q -t "${tmp_image_name}" -f Dockerfile ."
	echo "CMD: ${cmd}"
	${cmd}

	check_image_exists "${tmp_image_name}"
	if [ $? -eq 1 ]; then
		echo "ERROR: Building temporary image failed"
		exit 1
	fi
}

run_container() {
	./run_app_docker_image.sh "${tmp_image_name}" "${container_name}"

	check_container_running "${tmp_image_name}" "${container_name}"
	if [ $? -eq 1 ]; then
		echo "ERROR: Did not find container "${container_name}""
		exit 1
	fi
}

wait_for_checkpoint() {
        local retry_counter=0
        while true;
        do
                echo "INFO: Waiting for checkpoint (retry count: "${retry_counter}")"

		check_container_running "${tmp_image_name}" "${container_name}"
		if [ $? -eq 1 ]; then
			echo "ERROR: container has stopped"
			exit 1
		fi

                docker logs --tail=1 "${container_name}" | grep "${CHECKPOINT_SUCCESS_MSG}" &> /dev/null

                if [ $? -eq 0 ]; then
                        echo "INFO: Checkpoint done."
                        break
                fi
                if [ "${retry_counter}" -eq ${TIMEOUT} ]; then
                        echo "ERROR: Checkpoint timed out"
                        exit 1
                fi
                retry_counter=$(($retry_counter+1))
                sleep 1s
        done
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

	cmd="docker rm "${container_name}""
	echo "CMD: ${cmd}"
	${cmd} &> /dev/null
}

build_docker_image
run_container
wait_for_checkpoint
commit_container

