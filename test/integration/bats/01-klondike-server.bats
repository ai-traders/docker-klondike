load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

volumes_root="/tmp/docker-klondike-itest"
volume_data="${volumes_root}/data"
network="klondike-itest-net"
container="klondike-itest"
container_client="klondike-itest-client"

@test "initialize tests" {
  if [[ "${volume_data}" == "" ]]; then
    echo "fail! volume_data not set"
    return 1
  fi
  docker stop ${container} || echo "No ${container} container to stop"
  docker rm ${container} || echo "No ${container} container to remove"
  docker network rm ${network} || echo "No ${network} network to remove"
  sudo rm -rf "${volumes_root}"
  # those directories will be cinder volumes, so make this closer to production
  mkdir -p "${volume_data}/lost+found"
  docker network create --driver bridge ${network}
}
@test "klondike server is running" {
  run docker run -d -p 8080:8080 --name ${container} \
    --net="${network}" \
    -v "${volume_data}":/app/App_Data/Packages \
    ${this_image_name}:${this_image_tag}
  assert_equal "$status" 0

  # Do not use this line, because not only we care that the endpoint is reachable,
  # but we also care that its output contains a specified string:
  # run /bin/bash -c "curl --retry 30 localhost:8080"
  # Wait here max 30 seconds for klondike server to be initialized and running.
  run /bin/bash -c "for i in {1..30}; do { echo \"trial: \$i\" && curl --silent localhost:8080 | grep \"Klondike - NuGet Package Repository\"; } && break || { sleep 1; [[ \$i == 30 ]] && exit 1; } done"
  assert_equal "$status" 0
}

@test "there are 0 packages now in klondike server" {
  run /bin/bash -c "curl localhost:8080/api/packages"
  assert_output --partial "\"count\": 0"
  assert_equal "$status" 0
}

@test "docker logs shows klondike server logs" {
  run docker logs ${container}
  assert_output --partial "Klondike"
  assert_output --partial "NuGet"
  assert_output --partial "Listening for HTTP requests on address(es): http://*:8080/"
  assert_equal "$status" 0
}

@test "a nuget package can be pushed to klondike" {
  cd test/integration/test-files/Dummy.TestPackage
  run docker run --rm --name ${container_client} \
    --entrypoint=/bin/bash \
    --net="${network}" \
    -v $(pwd):/tmp/work \
    microsoft/dotnet:1.1.2-sdk-1.0.4 \
    -c "cd /tmp/work && dotnet restore && dotnet pack /p:PackageVersion=0.1.331 && dotnet nuget push ./bin/Debug/Dummy.TestPackage.0.1.331.nupkg  --source http://klondike-itest:8080/api/odata"
  assert_output --partial "Pushing Dummy.TestPackage.0.1.331.nupkg to 'http://klondike-itest:8080/api/odata'"
  assert_output --partial "info : Your package was pushed"
  assert_equal "$status" 0
}

@test "the pushed nuget package is visible on klondike server filesystem" {
  run docker exec ${container} /bin/bash -c "ls -la /app/App_Data/Packages/Dummy.TestPackage/"
  assert_output --partial "Dummy.TestPackage.0.1.331.nupkg"
  assert_equal "$status" 0
}
@test "the pushed nuget package is visible through klondike server API" {
  run /bin/bash -c "curl localhost:8080/api/packages | grep Dummy -A 5 -B 5"
  assert_output --partial "Dummy.TestPackage"
  assert_output --partial "0.1.331"
  assert_equal "$status" 0
}

@test "klondike container can be restarted" {
  run docker restart ${container}
  assert_output --partial "${container}"
  assert_equal "$status" 0
  # give it up to 15s to be running
  run /bin/bash -c "for i in {1..15}; do { echo \"trial: \$i\" && curl --silent localhost:8080 | grep \"Klondike - NuGet Package Repository\"; } && break || { sleep 1; [[ \$i == 15 ]] && exit 1; } done"
  assert_equal "$status" 0

  # the container is running and the dummy nuget package is visible
  run /bin/bash -c "curl localhost:8080/api/packages | grep Dummy -A 5 -B 5"
  assert_output --partial "Dummy.TestPackage"
  assert_output --partial "0.1.331"
  assert_equal "$status" 0
}

@test "klondike server data is persistent if container recreated" {
  # remove container
  run docker stop ${container}
  assert_output --partial "${container}"
  assert_equal "$status" 0
  run docker rm ${container}
  assert_output --partial "${container}"
  assert_equal "$status" 0

  # recreate container
  docker run -d -p 8080:8080 --name ${container} \
    --net="${network}" \
    -v "${volume_data}":/app/App_Data/Packages \
    ${this_image_name}:${this_image_tag}
  # give it up to 15s to be running
  run /bin/bash -c "for i in {1..15}; do { echo \"trial: \$i\" && curl --silent localhost:8080 | grep \"Klondike - NuGet Package Repository\"; } && break || { sleep 1; [[ \$i == 15 ]] && exit 1; } done"
  assert_equal "$status" 0

  # the container is running and the dummy nuget package is visible
  run /bin/bash -c "curl localhost:8080/api/packages | grep Dummy -A 5 -B 5"
  assert_output --partial "Dummy.TestPackage"
  assert_output --partial "0.1.331"
  assert_equal "$status" 0

  # visible on filesystem
  run docker exec ${container} /bin/bash -c "ls -la /app/App_Data/Packages/Dummy.TestPackage/"
  assert_output --partial "Dummy.TestPackage.0.1.331.nupkg"
  assert_equal "$status" 0
}

# how to test mirror?

# test paket install?
