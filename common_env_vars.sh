#!/bin/bash

DOCKER_IMAGE_OS=ubuntu

TIMEOUT=100
CONTAINER_USER=root

CR_LOG_DIR="/opt/appcr/cr_logs"
DUMP_LOG_FILE="dump.log"
RESTORE_LOG_FILE="restore.log"

# This is the list of additional capabilities required for using criu
DOCKER_CAPABILITIES="--cap-add AUDIT_CONTROL --cap-add DAC_READ_SEARCH --cap-add NET_ADMIN --cap-add SYS_ADMIN --cap-add SYS_PTRACE --cap-add SYS_RESOURCE"
DOCKER_SECURITY_OPTS="--security-opt apparmor=unconfined --security-opt seccomp=unconfined"

# Add application specific env variables here
