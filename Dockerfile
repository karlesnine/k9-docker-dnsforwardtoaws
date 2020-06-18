FROM ubuntu:18.04

# Conf Apt
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ENV DEBIAN_FRONTEND=noninteractive

# Install base
RUN apt-get update
RUN apt-get install -y apt-utils apt-transport-https
RUN apt-get upgrade -y

# install bind and curl
RUN apt-get install -y bind9 bind9utils curl prometheus-bind-exporter

RUN  mkdir -p /var/run/named

# customised config to be a DNS forwarder
COPY named.conf.options.template /etc/bind/named.conf.options.template
# start script to template in VPC DNS IP
COPY startdns.sh /startdns.sh
RUN chmod a+x /startdns.sh

EXPOSE 9153 53 53/udp


CMD ["/startdns.sh"]
