#!/bin/bash

# trampoline script to start the application

app_image=$1
app_container=$2

./run_acmeair.sh $@
