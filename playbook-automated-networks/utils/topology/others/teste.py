from mininet.net import Containernet
from mininet.node import Controller, Docker
from mininet.cli import CLI
from time import sleep

# Inicializar a rede Containernet
net = Containernet(controller=Controller)

# Adicionar controlador
net.addController('c0')

# Adicionar roteadores
router1 = net.addDocker('router1', ip='192.168.1.1', dimage="ubuntu:trusty")
router2 = net.addDocker('router2', ip='192.168.2.1', dimage="ubuntu:trusty")
router3 = net.addDocker('router3', ip='192.168.3.1', dimage="ubuntu:trusty")

# Adicionar hosts
host1 = net.addDocker('host1', ip='192.168.1.10', dimage="ubuntu:trusty", defaultRoute='via 192.168.1.1')
host3 = net.addDocker('host3', ip='192.168.3.30', dimage="ubuntu:trusty", defaultRoute='via 192.168.3.1')

# Adicionar links seriais entre roteadores
net.addLink(router1, router2, cls=None, params1={'ip':'10.0.0.1/30'}, params2={'ip':'10.0.0.2/30'})
net.addLink(router2, router3, cls=None, params1={'ip':'10.0.0.5/30'}, params2={'ip':'10.0.0.6/30'})

# Iniciar a rede
net.start()

# Aguardar um momento para que os containers inicializem
sleep(5)

# Configurar interfaces dos roteadores
for router, interface, ip in [(router1, 'router1-eth0', '192.168.1.1/24'),
                               (router2, 'router2-eth0', '192.168.2.1/24'),
                               (router3, 'router3-eth0', '192.168.3.1/24')]:
    router.cmd(f'ifconfig {interface} {ip}')

# Adicionar rotas nos roteadores
for router, route in [(router1, 'ip route add 192.168.3.0/24 via 10.0.0.2'),
                      (router2, 'ip route add 192.168.1.0/24 via 10.0.0.1'),
                      (router2, 'ip route add 192.168.3.0/24 via 10.0.0.6'),
                      (router3, 'ip route add 192.168.1.0/24 via 10.0.0.5')]:
    router.cmd(route)

# Configurar roteamento nos hosts
for host, route in [(host1, 'ip route add 192.168.1.10 via 192.168.1.1'),
                    (host3, 'ip route add 192.168.3.30 via 192.168.3.1')]:
    host.cmd(route)

# Permitir roteamento nos roteadores
for router in [router1, router2, router3]:
    router.cmd('sysctl -w net.ipv4.ip_forward=1')

# Iniciar a CLI
CLI(net)

# Parar a rede
net.stop()
