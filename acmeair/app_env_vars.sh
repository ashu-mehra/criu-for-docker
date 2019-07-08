#!/bin/bash

DOCKER_IMAGE_OS=ubuntu
CONTAINER_USER=default

LOG_MESSAGE="The defaultServer server is ready to run a smarter planet"
LOG_LOCATION="/logs/messages.log"

APP_DOCKER_IMAGE="ashumehra/acmeair-monolithic:latest"
APP_CR_DOCKER_IMAGE="ashumehra/acmeair-cr-monolithic:latest"

ACMEAIR_CONTAINER="acmeair-server"
