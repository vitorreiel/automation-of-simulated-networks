#!/usr/bin/python

from mininet.net import Containernet
from mininet.node import Controller
from mininet.node import Node
from mininet.cli import CLI
from mininet.link import TCLink
from mininet.log import info, setLogLevel

import sys

def topology(args):

    "Create a network."
    net = Containernet(controller=Controller)

    info("*** Creating nodes\n")

    # Creating 1 host per switch
    hosts = []
    for i in range(1, 13):
        host = net.addDocker(f'host{i}', mac=f'00:00:00:00:00:{i:02x}', ip=f'10.0.{i}.1/24', dimage="alpine-user:latest", defaultRoute=f'via 10.0.{i}.254')
        hosts.append(host)

    # Creating 12 switches
    switches = []
    for i in range(1, 13):
        switch = net.addSwitch(f's{i}')
        switches.append(switch)

    c1 = net.addController('c1')

    info("*** Associating and Creating links\n")

    # Connecting each host to a switch
    for i in range(12):
        net.addLink(hosts[i], switches[i])

    # Creating the ring topology by connecting each switch to the next
    for i in range(12):
        net.addLink(switches[i], switches[(i + 1) % 12], cls=TCLink)

    info("*** Starting network\n")
    net.start()

    info("*** Running CLI\n")
    CLI(net)

    info("*** Stopping network\n")
    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    topology(sys.argv)
