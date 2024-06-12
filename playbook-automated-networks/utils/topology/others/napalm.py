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

    hostA = net.addDocker('Host-A', mac='00:00:00:00:00:40', ip='192.168.0.1/24', dimage="alpine-user:latest", defaultRoute='via 192.168.10.1')
    hostB = net.addDocker('Host-B', mac='00:00:00:00:00:40', ip='10.0.20.100/24', dimage="alpine-user:latest", defaultRoute='via 10.0.20.254')

    suporte = net.addDocker('suporte', mac='00:00:00:00:00:10', ip='10.0.10.100/24', dimage="blue-team:latest", defaultRoute='via 10.0.10.254')
    servSamba = net.addDocker('servSamba', mac='00:00:00:00:00:20', ip='10.0.30.100/24', dimage="dperson/samba:latest", dcmd='/sbin/tini -- /usr/bin/samba.sh -p -u "suporte;badpass" -u "joao;joao123" -s "joao;/home/joao;yes;no;no;joao,suporte" -s "suporte;/home/suporte;yes;no;no;suporte"',ports=[139, 445], defaultRoute='via 10.0.30.254')
    servWeb = net.addDocker('servWeb', mac='00:00:00:00:00:30', ip='100.0.0.101/24', dimage="web-server:latest", dcmd="/bin/sh -c /start.sh", ports=[22,40157], defaultRoute='via 100.0.0.254')
    joao = net.addDocker('joao', mac='00:00:00:00:00:40', ip='10.0.20.100/24', dimage="alpine-user:latest", defaultRoute='via 10.0.20.254')
    gustavo = net.addDocker('gustavo', mac='00:00:00:00:00:50', ip='10.0.20.101/24', dimage="alpine-user:latest", defaultRoute='via 10.0.20.254')
    gabriele = net.addDocker('gabriele', mac='00:00:00:00:00:60', ip='10.0.20.102/24', dimage="alpine-user:latest", defaultRoute='via 10.0.20.254')
    henrique = net.addDocker('henrique', mac='00:00:00:00:00:70', ip='10.0.20.103/24', dimage="ddos-attack:latest", dcmd="/bin/sh -c /ddos.sh", environment={"TARGET_IP":"10.0.30.100"}, defaultRoute='via 10.0.20.254')
    joyce = net.addDocker('joyce', mac='00:00:00:00:00:80', ip='10.0.20.104/24', dimage="ddos-attack:latest", dcmd="/bin/sh -c /ddos.sh", environment={"TARGET_IP":"10.0.30.100"}, defaultRoute='via 10.0.20.254')
    internet = net.addDocker('internet', mac='00:00:00:00:00:90', ip='1.178.218.56/24', dimage="dic-attack-ssh:latest", dcmd="/bin/sh -c /dic_attack_ssh.sh", environment={"TARGET_IP":"100.0.0.101"}, defaultRoute='via 1.178.218.254')


    c1 = net.addController('c1')

    info('*** Adding switches\n')
    s1 = net.addSwitch('s1')
    s2 = net.addSwitch('s2')
    s3 = net.addSwitch('s3')
    s4 = net.addSwitch('s4')
    s5 = net.addSwitch('s5')

    port1 = net.addSwitch('port1')
    port2 = net.addSwitch('port2')
    port3 = net.addSwitch('port3')
    port4 = net.addSwitch('port4')
    port5 = net.addSwitch('port5')

    info('*** Adding routers\n')
    defaultIP = '10.0.10.254/24'
    router = net.addHost( 'r0', cls=LinuxRouter, ip=defaultIP)

    info("*** Associating and Creating links\n")
    net.addLink(port1, router, intfName2='r0-eth1', params2={ 'ip' : defaultIP } )
    net.addLink(port2, router, intfName2='r0-eth2', params2={ 'ip' : '10.0.20.254/24' } )
    net.addLink(port3, router, intfName2='r0-eth3', params2={ 'ip' : '10.0.30.254/24' } )
    net.addLink(port4, router, intfName2='r0-eth4', params2={ 'ip' : '100.0.0.254/24' } )
    net.addLink(port5, router, intfName2='r0-eth5', params2={ 'ip' : '1.178.218.254/24' } )

    net.addLink(suporte, s1)#, cls=TCLink, delay='100ms', bw=1)
    net.addLink(servSamba, s3)
    net.addLink(servWeb, s4)
    net.addLink(joao, s2)
    net.addLink(gustavo, s2)
    net.addLink(gabriele, s2)
    net.addLink(henrique, s2)
    net.addLink(joyce, s2)
    net.addLink(internet, s5)

    net.addLink(s1, port1)
    net.addLink(s2, port2)
    net.addLink(s3, port3)
    net.addLink(s4, port4)
    net.addLink(s5, port5)

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