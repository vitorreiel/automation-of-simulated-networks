#!/bin/bash
# apt install curl openvswitch-switch -y
# [ Build ]
docker build $(pwd)/device-images/user-image/ -t alpine-user
docker build $(pwd)/device-images/containernet-image/ -t containernet

# [ Start ]
docker run -d --name containernet -it --rm --privileged --pid='host' -v /var/run/docker.sock:/var/run/docker.sock --mount type=bind,source=$(pwd)/napalm-topology,target=/vrml containernet python3 /vrml/teste.py
# docker attach containernet
# docker exec -it mn.router1 bash