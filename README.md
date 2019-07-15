# criu-for-docker
Automate the process of creating a Docker image containing application checkpoint using CRIU

## Scripts run on host

**driver.sh:** Main script that creates a temporary docker image, starts the container, creates the checkpoint, and commits the container to create new image with the checkpoint.

**Dockerfile.\<os\>:** Used by `driver.sh` to create a temporary docker image that has `criu` and other scripts for starting the application and restoring it from the checkpoint.

## Scripts run in the container

**appcr.sh:** Entry point for the docker container. If the checkpoint is not yet done, it will start the applicatio. If the checkpoint exists, it restores the application from the checkpoint.

## Application specific changes

For a new application create a directory, lets say `mytest` at the same level as `driver.sh` script. Inside the directory add following files:

**run_mytest.sh:** This script is called by `driver.sh` to start the application docker image. It is passed three parameters:
  - application name, eg in this case it would be `mytest`
  - application docker image
  - container name
  
**run_app.sh:** This script is added to the temporary docker image created by `driver.sh`. It should contain the commands to start the application in the docker container.

**app_env_vars.sh:** This is a template file present at the top level of this project. Copy it to your application directory, in this case `mytest`. It contains application specific environment variables and need to be updated for each application.

## Workflow

This section assumes there exists a directory `mytest` for the application.
Top level script is `driver.sh`. It is to be invoked as:

`$ ./driver.sh mytest`

It creates a new temporary docker images using `mytest/Dockerfile.\<os\>` file and invokes `mytest/run_mytest.sh`.
`run_mytest.sh` starts the docker container using the temporary image. Inside the container, the entry point is set to `run_app.sh` which starts the application.
The `driver.sh` scripts keeps grep-ing `docker logs` to find the string which indicates the application is up and running.
At this point, it using `criu dump` to create the checkpoint and commit the container to create new docker image containing the application checkpoint.

## Examples

Look at [acmeair](https://github.com/ashu-mehra/criu-for-docker/tree/master/acmeair) and [jenkins](https://github.com/ashu-mehra/criu-for-docker/tree/master/jenkins) directory as examples of the applications using this mechanism.
