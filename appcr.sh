#!/bin/bash

source ./app.sh

restore_from_checkpoint() {
	criu restore --tcp-established -j -v4 -o ${CR_LOG_DIR}/${RESTORE_LOG_FILE}
}

stop_app() {
	./app.sh "stop"
}

app_started() {
	if [ ! -f ${CR_LOG_DIR}/${APP_PID_FILE} ]; then
		echo "ERROR: ${CR_LOG_DIR}/${APP_PID_FILE} file not found"
		exit 1;
	fi
	local app_pid=`cat ${CR_LOG_DIR}/${APP_PID_FILE}`
	echo "INFO: Application PID is ${app_pid}"
	./create_checkpoint.sh "${app_pid}"
        if [ $? -eq 0 ]; then
                echo "INFO: ${CHECKPOINT_SUCCESS_MSG}"
		wait 
        else
                echo "ERROR: ${CHECKPOINT_FAILED_MSG}"
		stop_app
	fi
}

if [ -f ${CR_LOG_DIR}/${DUMP_LOG_FILE} ]; then
	# checkpointing is already done, restore the app from the checkpoint
	echo "INFO: Found checkpoint, restoring the app from the checkpoint"
	restore_from_checkpoint
else
	# checkpoint does not exist, run the app and checkpoint it
	echo "INFO: Starting the app to checkpoint it"
	trap stop_app SIGUSR1 # register a handler that stops the application when driver script generates SIGUSR1 signal
	start_app "$@"
	#./app.sh "start" "${pid}" "$@" 
	if [ $? -eq 0 ]; then
		app_started
	else
		echo "ERROR: Application failed to start"
	fi
fi
