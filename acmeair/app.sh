#!/bin/bash

source ./common_env_vars.sh

check_server_started() {
        local retry_counter=0
        while true;
        do
                echo "INFO: Checking if application started (retry counter=${retry_counter})"
                grep "${LOG_MESSAGE}" "${LOG_LOCATION}" &> /dev/null
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

get_server_pid() {
	echo `ps -ef | grep java | grep -v grep | awk '{ print $2 }'`
}

start_app() {
	/opt/ibm/helpers/runtime/docker-server.sh /opt/ibm/wlp/bin/server run defaultServer &
	check_server_started
	if [ $? -eq 0 ]; then
		app_pid=$(get_server_pid)
		echo "INFO: Writing app pid ${app_pid} to ${CR_LOG_DIR}/${APP_PID_FILE}"
		echo "${app_pid}" > ${CR_LOG_DIR}/${APP_PID_FILE}
	fi
}

stop_app() {
	echo "Stopping application"
	/opt/ibm/wlp/bin/server stop defaultServer
}

