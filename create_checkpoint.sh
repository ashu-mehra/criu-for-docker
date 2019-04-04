#!/bin/bash

app_pid=$1
if [ -z "${app_pid}" ]; then
	echo "ERROR: Missing pid"
	exit 1
fi
echo "INFO: Checkpointing PID ${app_pid}"

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

check_pid_exists ${app_pid}
if [ $? -eq 0 ]; then
	echo "CMD: criu dump -t ${app_pid} --tcp-established -j --leave-running -v4 -o ${CR_LOG_DIR}/${DUMP_LOG_FILE}"
	criu dump -t "${app_pid}" --tcp-established -j --leave-running -v4 -o "${CR_LOG_DIR}/${DUMP_LOG_FILE}"
else
	echo "ERROR: pid ${app_pid} does not exist"
fi
