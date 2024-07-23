#!/usr/bin/python

from mininet.net import Containernet
from mininet.node import Controller
from mininet.node import Node
from mininet.cli import CLI
from mininet.link import TCLink
from mininet.log import info, setLogLevel

import sys
import time

class LinuxRouter( Node ):
    "A Node with IP forwarding enabled."

    def config( self, **params ):
        super( LinuxRouter, self).config( **params )
        self.cmd( 'sysctl net.ipv4.ip_forward=1')

    def terminate( self ):
        self.cmd( 'sysctl net.ipv4.ip_forward=0' )
        super( LinuxRouter, self ).terminate()

def topology(args):

    "Create a network."
    net = Containernet(controller=Controller)

    info("*** Creating nodes\n")

    hostA1 = net.addDocker('host-a1', mac='00:00:00:00:00:11', ip='10.0.10.101/24', dimage="alpine-user:latest", defaultRoute='via 10.0.10.254')
    hostB1 = net.addDocker('host-b1', mac='00:00:00:00:00:21', ip='10.0.20.101/24', dimage="alpine-user:latest", defaultRoute='via 10.0.20.254')
    hostB2 = net.addDocker('host-b2', mac='00:00:00:00:00:22', ip='10.0.20.102/24', dimage="alpine-user:latest", defaultRoute='via 10.0.20.254')
    hostC1 = net.addDocker('host-c1', mac='00:00:00:00:00:31', ip='10.0.30.101/24', dimage="alpine-user:latest", defaultRoute='via 10.0.30.254')
    hostC2 = net.addDocker('host-c2', mac='00:00:00:00:00:32', ip='10.0.30.102/24', dimage="alpine-user:latest", defaultRoute='via 10.0.30.254')
    hostC3 = net.addDocker('host-c3', mac='00:00:00:00:00:33', ip='10.0.30.103/24', dimage="alpine-user:latest", defaultRoute='via 10.0.30.254')

    c1 = net.addController('c1')

    info('*** Adding switches\n')
    rootSwitch = net.addSwitch('s1')
    level1Switch1 = net.addSwitch('s2')
    level1Switch2 = net.addSwitch('s3')

    info('*** Adding routers\n')
    defaultIP = '10.0.10.254/24'
    router = net.addHost( 'r0', cls=LinuxRouter, ip=defaultIP)

    info("*** Associating and Creating links\n")
    net.addLink(rootSwitch, level1Switch1)
    net.addLink(rootSwitch, level1Switch2)

    net.addLink(hostA1, level1Switch1)
    net.addLink(hostB1, level1Switch1)
    net.addLink(hostB2, level1Switch2)
    net.addLink(hostC1, level1Switch2)
    net.addLink(hostC2, level1Switch2)
    net.addLink(hostC3, level1Switch2)

    net.addLink(rootSwitch, router, intfName2='r0-eth1', params2={ 'ip' : defaultIP } )

    info("*** Starting network\n")
    net.start()

    info( '*** Routing Table on Router:\n' )
    print((net['r0'].cmd('route')))

    info("*** Running CLI\n")
    CLI(net)

    info("*** Stopping network\n")
    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    topology(sys.argv)
