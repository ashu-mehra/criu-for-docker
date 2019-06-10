#!/bin/bash

source ./common_env_vars.sh
source ./app.sh

check_pid_restore_possible() {
	for pid in `crit x . ps| tail -n +2 | awk '{ print $1 }'`; do
		ps -eLo 'pid' | grep ${pid} > /dev/null
		if [ $? -eq 0 ]; then
			echo "ERROR: PID ${pid} is already present"
			return 1
		fi
	done
	return 0
}

restore_from_checkpoint() {
	check_pid_restore_possible
	if [ $? -eq 0 ]; then
		cmd="sudo criu restore --tcp-established -j -v3 -o ${CR_LOG_DIR}/${RESTORE_LOG_FILE}"
		echo "CMD: ${cmd}"
		${cmd}
		# if we reach here, it means criu restore didn't complete properly
		# Using tee in above command to display the logs and send it to restore.log file does not work.
		# Display restore.log on stdout
		sudo chmod 755 ${CR_LOG_DIR}/${RESTORE_LOG_FILE}
		cat ${CR_LOG_DIR}/${RESTORE_LOG_FILE}
	fi
}

check_pid_exists() {
	local pid=$1
	if [ -d "/proc/${pid}" ]; then
		echo "INFO: Found /proc/${pid}"
		return 0
	else
		echo "INFO: Did not find /proc/${pid}"
		return 1
	fi
}

create_checkpoint() {
	app_pid=$1
	check_pid_exists ${app_pid}
	if [ $? -eq 0 ]; then
		cmd="sudo criu dump -t "${app_pid}" --tcp-established -j --leave-running -v4 -o "${CR_LOG_DIR}/${DUMP_LOG_FILE}""
		echo "CMD: ${cmd}"
		${cmd}
		sudo chmod 755 "${CR_LOG_DIR}/${DUMP_LOG_FILE}"
	else
		echo "ERROR: pid ${app_pid} does not exist"
	fi
}

app_started() {
	if [ ! -f ${CR_LOG_DIR}/${APP_PID_FILE} ]; then
		echo "ERROR: ${CR_LOG_DIR}/${APP_PID_FILE} file not found"
		exit 1;
	fi
	local app_pid=`cat ${CR_LOG_DIR}/${APP_PID_FILE}`
	echo "INFO: Application PID is ${app_pid}"
	create_checkpoint "${app_pid}"
        if [ $? -eq 0 ]; then
                echo "INFO: ${CHECKPOINT_SUCCESS_MSG}"
		wait 
        else
                echo "ERROR: ${CHECKPOINT_FAILED_MSG}"
		stop_app # from app.sh
	fi
}

# by default /proc is read-only in docker container,
# remount it as read-write
sudo umount -R /proc
sudo mount -t proc proc /proc
APP_START_PID=100
trap stop_app SIGTERM # register a handler that stops the application when driver script stops the container

if [ -f ${CR_LOG_DIR}/${DUMP_LOG_FILE} ]; then
	# checkpointing is already done, restore the app from the checkpoint
	echo "INFO: Found checkpoint, restoring the app from the checkpoint"
	restore_from_checkpoint
else
	# checkpoint does not exist, run the app and checkpoint it
	echo "INFO: Starting the app to checkpoint it"
	sudo /bin/echo ${APP_START_PID} > /proc/sys/kernel/ns_last_pid
	start_app "$@" # from app.sh
	if [ $? -eq 0 ]; then
		app_started
	else
		echo "ERROR: Application failed to start"
	fi
fi
