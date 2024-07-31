#!/usr/bin/python

from mininet.net import Containernet
from mininet.node import Controller
from mininet.cli import CLI
from mininet.link import TCLink
from mininet.log import info, setLogLevel

import sys

def topology(args):

    "Create a network."
    net = Containernet(controller=Controller)

    info("*** Creating nodes\n")

    # Creating hosts
    hosts = []
    for i in range(1, 13):
        host = net.addDocker(f'H{i}', mac=f'00:00:00:00:00:{i:02x}', ip=f'10.0.{i}.1/24', dimage="alpine-user:latest", defaultRoute=f'via 10.0.{i}.254')
        hosts.append(host)

    # Creating switches
    switches = []
    for i in range(1, 14):
        switch = net.addSwitch(f'S{i}')
        switches.append(switch)

    c1 = net.addController('C1')

    info("*** Associating and Creating links\n")

    # Connecting the root switch to 4 level 1 switches
    rootSwitch = switches[0]
    for i in range(1, 5):
        net.addLink(rootSwitch, switches[i])

    # Connecting each level 1 switch to 1 host and 2 level 2 switches
    hostIndex = 0
    switchIndex = 5
    for i in range(1, 5):
        net.addLink(switches[i], hosts[hostIndex])
        hostIndex += 1
        for j in range(2):
            net.addLink(switches[i], switches[switchIndex])
            net.addLink(switches[switchIndex], hosts[hostIndex])
            hostIndex += 1
            switchIndex += 1

    info("*** Starting network\n")
    net.start()

    info("*** Running CLI\n")
    CLI(net)

    info("*** Stopping network\n")
    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    topology(sys.argv)
