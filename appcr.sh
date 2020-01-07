#!/bin/bash

source ./common_env_vars.sh
source ./app_env_vars.sh

run() {
	if [ ${CONTAINER_USER} = "root" ]; then
		$@
	else
		sudo $@
	fi
}

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
		beforeRestore=`date +"%s.%3N"`
		echo "before restore: ${beforeRestore}"
		cmd="criu restore --tcp-established -j -v3 -o ${CR_LOG_DIR}/${RESTORE_LOG_FILE}"
		echo "CMD: ${cmd}"
		run ${cmd}
		# if we reach here, it means criu restore didn't complete properly
		# Using tee in above command to display the logs and send it to restore.log file does not work.
		# Display restore.log on stdout
		run chmod 755 ${CR_LOG_DIR}/${RESTORE_LOG_FILE}
		cat ${CR_LOG_DIR}/${RESTORE_LOG_FILE}
	fi
}

# by default /proc is read-only in docker container,
# remount it as read-write
onEntry=`date +"%s.%3N"`
echo "onEntry: ${onEntry}"
run umount -R /proc
run mount -t proc proc /proc
afterRemount=`date +"%s.%3N"`
echo "after mounting proc as read-write: ${afterRemount}"
APP_START_PID=100

if [ -f ${CR_LOG_DIR}/${DUMP_LOG_FILE} ]; then
	# checkpointing is already done, restore the app from the checkpoint
	echo "INFO: Found checkpoint, restoring the app from the checkpoint"
	restore_from_checkpoint
else
	# checkpoint does not exist, run the app and checkpoint it
	echo "INFO: Starting the app to checkpoint it"
	run /bin/echo ${APP_START_PID} > /proc/sys/kernel/ns_last_pid
	./run_app.sh $@

	trap 'quit=1' TERM
	quit=0

	while [ "$quit" -eq 0 ]; do
		echo "Waiting for TERM signal"
		sleep 1
	done
fi
