#!/bin/bash
# [ Build ]
dest="/opt/network-components"
docker build "${dest}/device-images/alpine-image/" -t alpine-user
docker build "${dest}/device-images/containernet-image/" -t containernet

# [ Start ]
docker run -d --name containernet -it --rm --privileged --pid='host' -v /var/run/docker.sock:/var/run/docker.sock --mount type=bind,source="${dest}/serial-topology",target=/vrml containernet python3 /vrml/topology.py
# docker attach containernet
# docker exec -it mn.router1 bash'