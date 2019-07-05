#!/bin/bash

DOCKER_IMAGE_OS=debian

LOG_MESSAGE="Jenkins is fully up and running"
LOG_LOCATION=stdout
TIMEOUT=100
CONTAINER_USER=root

CR_LOG_DIR="/opt/appcr/cr_logs"
DUMP_LOG_FILE="dump.log"
RESTORE_LOG_FILE="restore.log"

APP_DOCKER_IMAGE="jenkins/jenkins"
APP_CR_DOCKER_IMAGE="jenkins-checkpoint"

# This is the list of additional capabilities required for using criu
DOCKER_CAPABILITIES="--cap-add AUDIT_CONTROL --cap-add DAC_READ_SEARCH --cap-add NET_ADMIN --cap-add SYS_ADMIN --cap-add SYS_PTRACE --cap-add SYS_RESOURCE"
DOCKER_SECURITY_OPTS="--security-opt apparmor=unconfined --security-opt seccomp=unconfined"

# Add application specific env variables here
