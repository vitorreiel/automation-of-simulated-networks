FROM alpine:latest
LABEL maintainer=”RafaelPinheiro”
RUN apk update 
RUN apk add bash \ 
	tcpdump \
	iperf \
	busybox-extras \
	iproute2 \
	iputils

RUN apt-get install -y python3-pip && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

RUN pip3 install netmiko nornir napalm

CMD ["/bin/sh"]