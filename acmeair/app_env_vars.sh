#!/bin/bash

DOCKER_IMAGE_OS=ubuntu
CONTAINER_USER=default

LOG_MESSAGE="The defaultServer server is ready to run a smarter planet"
LOG_LOCATION="/logs/messages.log"

APP_DOCKER_IMAGE="liberty-acmeair"
APP_CR_DOCKER_IMAGE="liberty-acmeair-cr"

ACMEAIR_CONTAINER="acmeair"
MONGO_DB_IMAGE="mongo-acmeair"
MONGO_DB_CONTAINER="mongodb"

