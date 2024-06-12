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

    hostA = net.addDocker('Host-A', mac='00:00:00:00:00:10', ip='10.0.10.100/24', dimage="alpine-user:latest", defaultRoute='via 10.0.10.254')
    hostB = net.addDocker('Host-B', mac='00:00:00:00:00:20', ip='10.0.20.100/24', dimage="alpine-user:latest", defaultRoute='via 10.0.20.254')
    hostC = net.addDocker('Host-C', mac='00:00:00:00:00:30', ip='10.0.30.100/24', dimage="alpine-user:latest", defaultRoute='via 10.0.30.254')

    c1 = net.addController('c1')

    info('*** Adding switches\n')
    s1 = net.addSwitch('s1')
    s2 = net.addSwitch('s2')
    s3 = net.addSwitch('s3')

    port1 = net.addSwitch('port1')
    port2 = net.addSwitch('port2')
    port3 = net.addSwitch('port3')

    info('*** Adding routers\n')
    defaultIP = '10.0.10.254/24'
    router = net.addHost( 'r0', cls=LinuxRouter, ip=defaultIP)

    info("*** Associating and Creating links\n")
    net.addLink(port1, router, intfName2='r0-eth1', params2={ 'ip' : defaultIP } )
    net.addLink(port2, router, intfName2='r0-eth2', params2={ 'ip' : '10.0.20.254/24' } )
    net.addLink(port3, router, intfName2='r0-eth3', params2={ 'ip' : '10.0.30.254/24' } )

    net.addLink(hostA, s1)
    net.addLink(hostB, s2)
    net.addLink(hostC, s3)

    net.addLink(s1, port1)
    net.addLink(s2, port2)
    net.addLink(s3, port3)

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