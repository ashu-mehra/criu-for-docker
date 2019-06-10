#!/bin/bash

LOG_MESSAGE="The defaultServer server is ready to run a smarter planet"
LOG_LOCATION="/logs/messages.log"
TIMEOUT=100

CHECKPOINT_SUCCESS_MSG="Checkpoint success"
CHECKPOINT_FAILED_MSG="Checkpoint failed"

CR_LOG_DIR="/opt/appcr/cr_logs"
DUMP_LOG_FILE="dump.log"
RESTORE_LOG_FILE="restore.log"
APP_PID_FILE="app.pid"

APP_DOCKER_IMAGE="ashumehra/acmeair-monolithic:latest"
APP_CR_DOCKER_IMAGE="ashumehra/acmeair-cr-monolithic:latest"

# This is the list of additional capabilities required for using criu
DOCKER_CAPABILITIES="--cap-add AUDIT_CONTROL --cap-add DAC_READ_SEARCH --cap-add NET_ADMIN --cap-add SYS_ADMIN --cap-add SYS_PTRACE --cap-add SYS_RESOURCE"
DOCKER_SECURITY_OPTS="--security-opt apparmor=unconfined --security-opt seccomp=unconfined"

# Add application specific env variables here
ACMEAIR_CONTAINER="acmeair-server"
