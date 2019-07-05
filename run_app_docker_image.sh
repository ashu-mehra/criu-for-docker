#!/bin/bash

# trampoline script to start the application
test_case=$1
app_image=$2
app_container=$3

./${test_case}/run_${test_case}.sh $@
