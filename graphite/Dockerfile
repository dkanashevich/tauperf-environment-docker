FROM ubuntu:trusty

COPY config /config

COPY config/policy-rc.d /usr/sbin/policy-rc.d

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update &&\
	apt-get -f install &&\
	apt-get -y install wget &&\
	wget https://apt.puppetlabs.com/puppetlabs-release-precise.deb &&\
	dpkg -i puppetlabs-release-precise.deb &&\
	apt-get update &&\
	apt-get -y install puppet &&\
    puppet module install puppetlabs-stdlib

EXPOSE 80 8081 2003 2003/udp 2004 8125 8125/udp

CMD puppet apply /config/manifests/default.pp &&\
    tail -f /dev/null