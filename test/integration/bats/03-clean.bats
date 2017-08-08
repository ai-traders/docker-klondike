load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

volumes_root="/tmp/docker-klondike-itest"
volume_data="${volumes_root}/data"
network="klondike-itest-net"
container="klondike-itest"

@test "clean" {
  if [[ "${volume_data}" == "" ]]; then
    echo "fail! volume_data not set"
    return 1
  fi
  docker stop ${container} || echo "No ${container} container to stop"
  docker rm ${container} || echo "No ${container} container to remove"
  docker network rm ${network} || echo "No ${network} network to remove"
  sudo rm -rf "${volumes_root}"
}
