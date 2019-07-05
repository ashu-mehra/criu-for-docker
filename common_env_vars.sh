#!/bin/bash

DOCKER_IMAGE_OS=ubuntu

LOG_MESSAGE="<application specific message>"
LOG_LOCATION="<applicaton specific log file>"
TIMEOUT=100
CONTAINER_USER=root

CR_LOG_DIR="/opt/appcr/cr_logs"
DUMP_LOG_FILE="dump.log"
RESTORE_LOG_FILE="restore.log"

APP_DOCKER_IMAGE="<application docker image>"
APP_CR_DOCKER_IMAGE="<application docker image containing checkpoint>"

# This is the list of additional capabilities required for using criu
DOCKER_CAPABILITIES="--cap-add AUDIT_CONTROL --cap-add DAC_READ_SEARCH --cap-add NET_ADMIN --cap-add SYS_ADMIN --cap-add SYS_PTRACE --cap-add SYS_RESOURCE"
DOCKER_SECURITY_OPTS="--security-opt apparmor=unconfined --security-opt seccomp=unconfined"

# Add application specific env variables here
