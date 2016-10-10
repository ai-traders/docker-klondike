#!/bin/bash -ex

# This script just checks that the image is runnable and can run for 5 seconds.

source ./image/variables.sh
docker run -it -d -p 8080:8080 --name klondike ${this_image_name}:${this_image_tag}
sleep 5
if [[ $(docker inspect -f {{.State.Running}} klondike) != "true" ]]; then
  echo "Container: klondike is not running"
  # do not remove the container, so that its logs can be checked later
  exit 1
fi

docker stop klondike && docker rm klondike
exit 0
