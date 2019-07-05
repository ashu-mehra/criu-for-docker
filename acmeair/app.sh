#!/bin/bash

start_app() {
	/opt/ibm/helpers/runtime/docker-server.sh /opt/ibm/wlp/bin/server run defaultServer
}

