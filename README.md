# criu-for-docker
Automate the process of checkpoint-restore in Docker

## Scripts run on host

**driver.sh:** Main script that creates a temporary image, starts the container and commits the container to create new image with the checkpoint.

**run_app_docker_image.sh:** Trampoline script that just invokes the application specific script or commands for starting the containers. It has two variables `app_image` and `app_container` to indicate the docker image and container name to be used by the application specific code.

## Scripts run in the container

**appcr.sh:** Entry point for the docker container. If the checkpoint is not yet done, it will start the application and checkpoint it. If the checkpoint exists, it restores the application from the checkpoint.

**app.sh:** Contains two dummy functions `start_app` and `stop_app` to be completed by the application.

**create_checkpoint.sh:** Accepts an argument `pid` of the application and checkpoints it.

