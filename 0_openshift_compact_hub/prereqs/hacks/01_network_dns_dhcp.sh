#!/bin/bash


# 1) Install dnsmasq tools
printf "\n=========================\n"
printf "| Install dnsmasq tools |\n"
printf "=========================\n\n"

dnf install -y dnsmasq bind-utils


# 2) Configure dnsmasq for DHCP and DNS
printf "\n======================================\n"
printf "| Configure dnsmasq for DHCP and DNS |\n"
printf "======================================\n\n"

mkdir -pv /opt/dnsmasq-ipv4v6/

cat <<EOF > /opt/dnsmasq-ipv4v6/dnsmasq.conf
#######################################
# DHCP and DNS Configuration - Server #
#######################################

# On systems which support it, dnsmasq binds the wildcard address,
# even when it is listening on only some interfaces. It then discards
# requests that it shouldn't reply to. This has the advantage of
# working even when interfaces come and go and change address. If you
# want dnsmasq to really bind only the interfaces it is listening on,
# uncomment this option. About the only time you may need this is when
# running another nameserver on the same machine.
bind-dynamic

# If you want dnsmasq to listen for DHCP and DNS requests only on
# specified interfaces (and the loopback) give the name of the
# interface (eg eth0) here.
# Repeat the line for more than one interface.
interface=networkipv4v6

# Or you can specify which interface _not_ to listen on
except-interface=lo

# For debugging purposes, log each DNS query as it passes through
# dnsmasq.
log-queries

# Log lots of extra information about DHCP transactions.
log-dhcp

# Bogus private reverse lookups. All reverse lookups for private IP ranges
# (ie 192.168.x.x, etc) which are not found in /etc/hosts or the DHCP leases
# file are answered with "no such domain" rather than being forwarded upstream.
bogus-priv

# Should be set when dnsmasq is definitely the only DHCP server on a network.
# For DHCPv4, it changes the behaviour from strict RFC compliance so that DHCP
# requests on unknown leases from unknown hosts are not ignored. This allows new
# hosts to get a lease without a tedious timeout under all circumstances. It also
# allows dnsmasq to rebuild its lease database without each client needing to reacquire
# a lease, if the database is lost. For DHCPv6 it sets the priority in replies to 255
# (the maximum) instead of 0 (the minimum).
dhcp-authoritative

# Limits dnsmasq to the specified maximum number of DHCP leases. The default is 150.
# This limit is to prevent DoS attacks from hosts which create thousands of leases
# and use lots of memory in the dnsmasq process.
dhcp-lease-max=81

# Specify the userid to which dnsmasq will change after startup. Dnsmasq must normally
# be started as root, but it will drop root privileges after startup by changing id to
# another user. Normally this user is "nobody" but that can be over-ridden with this switch.
user=dnsmasq

# Specify the group which dnsmasq will run as. The defaults to "dip", if available,
# to facilitate access to /etc/ppp/resolv.conf which is not normally world readable.
group=dnsmasq


#############################################
# DHCP and DNS Configuration - Cluster IPv4 #
#############################################

# ------------------------------------ #
# DHCP Configurations - Network IPv4v6 #
# ------------------------------------ #
# Uncomment this to enable the integrated DHCP server, you need
# to supply the range of addresses available for lease and optionally
# a lease time. If you have more than one network, you will need to
# repeat this for each network on which you want to supply DHCP
# service.
dhcp-range=networkipv4v6,172.16.100.11,172.16.100.20,255.255.255.0,4h
dhcp-range=networkipv4v6,2620:52:0:1305::11,2620:52:0:1305::20,64,4h

# Override the default route supplied by dnsmasq, which assumes the
# router is the same machine as the one running dnsmasq.
dhcp-option=networkipv4v6,option:dns-server,172.16.100.1
dhcp-option=networkipv4v6,option6:dns-server,2620:52:0:1305::1

# Read DHCP host information from the specified file. If a directory is given,
# then read all the files contained in that directory in alphabetical order. The file
# contains information about one host per line. The format of a line is the same as text
# to the right of '=' in --dhcp-host. The advantage of storing DHCP host information in
# this file is that it can be changed without re-starting dnsmasq: the file will be re-read
# when dnsmasq receives SIGHUP.
dhcp-hostsfile=/opt/dnsmasq-ipv4v6/hosts.hostsfile

# Use the specified file to store DHCP lease information.
dhcp-leasefile=/opt/dnsmasq-ipv4v6/hosts.leases


# ----------------------------------- #
# DNS Configurations - Network IPv4v6 #
# ----------------------------------- #

# If the address range is given as ip-address/network-size, then a additional flag "local" may be
# supplied which has the effect of adding --local declarations for forward and reverse DNS queries.
domain=ipv6.virtual.cluster.lab

# Add domains which you want to force to an IP address here.
# The example below send any host in doubleclick.net to a local
# webserver.
address=/apps.ipv6.virtual.cluster.lab/172.16.100.2
#address=/apps.ipv6.virtual.cluster.lab/2620:52:0:1305::2

# Add A, AAAA and PTR records to the DNS. This adds one or more names to the DNS with
# associated IPv4 (A) and IPv6 (AAAA) records. A name may appear in more than one
# --host-record and therefore be assigned more than one address.
host-record=api.ipv6.virtual.cluster.lab,172.16.100.3
host-record=api-int.ipv6.virtual.cluster.lab,172.16.100.3
#host-record=api.ipv6.virtual.cluster.lab,2620:52:0:1305::3
#host-record=api-int.ipv6.virtual.cluster.lab,2620:52:0:1305::3
# ---
host-record=openshift-master-0.ipv6.virtual.cluster.lab,172.16.100.5
host-record=openshift-master-0.ipv6.virtual.cluster.lab,2620:52:0:1305::5
ptr-record=5.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.5.0.3.1.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa.,"openshift-master-0.ipv6.virtual.cluster.lab"
# ---
host-record=openshift-master-1.ipv6.virtual.cluster.lab,172.16.100.6
host-record=openshift-master-1.ipv6.virtual.cluster.lab,2620:52:0:1305::6
ptr-record=6.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.5.0.3.1.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa.,"openshift-master-1.ipv6.virtual.cluster.lab"
# ---
host-record=openshift-master-2.ipv6.virtual.cluster.lab,172.16.100.7
host-record=openshift-master-2.ipv6.virtual.cluster.lab,2620:52:0:1305::7
ptr-record=7.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.5.0.3.1.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa.,"openshift-master-2.ipv6.virtual.cluster.lab"
# ---
host-record=openshift-worker-0.ipv6.virtual.cluster.lab,172.16.100.8
host-record=openshift-worker-0.ipv6.virtual.cluster.lab,2620:52:0:1305::8
ptr-record=8.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.5.0.3.1.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa.,"openshift-worker-0.ipv6.virtual.cluster.lab"
# ---
host-record=openshift-worker-1.ipv6.virtual.cluster.lab,172.16.100.9
host-record=openshift-worker-1.ipv6.virtual.cluster.lab,2620:52:0:1305::9
ptr-record=9.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.5.0.3.1.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa.,"openshift-worker-1.ipv6.virtual.cluster.lab"
# ---
host-record=openshift-worker-2.ipv6.virtual.cluster.lab,172.16.100.10
host-record=openshift-worker-2.ipv6.virtual.cluster.lab,2620:52:0:1305::10
ptr-record=0.1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.5.0.3.1.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa.,"openshift-worker-2.ipv6.virtual.cluster.lab"
# ---
host-record=$(hostname -f),172.16.100.1
host-record=$(hostname -f),2620:52:0:1305::1
EOF

cat <<EOF > /opt/dnsmasq-ipv4v6/hosts.hostsfile
de:ad:be:ff:00:05,openshift-master-0,172.16.100.5
de:ad:be:ff:00:05,openshift-master-0,[2620:52:0:1305::5]

de:ad:be:ff:00:06,openshift-master-1,172.16.100.6
de:ad:be:ff:00:06,openshift-master-1,[2620:52:0:1305::6]

de:ad:be:ff:00:07,openshift-master-2,172.16.100.7
de:ad:be:ff:00:07,openshift-master-2,[2620:52:0:1305::7]

de:ad:be:ff:00:08,openshift-worker-0,172.16.100.8
de:ad:be:ff:00:08,openshift-worker-0,[2620:52:0:1305::8]

de:ad:be:ff:00:09,openshift-worker-1,172.16.100.9
de:ad:be:ff:00:09,openshift-worker-1,[2620:52:0:1305::9]

de:ad:be:ff:00:10,openshift-worker-2,172.16.100.10
de:ad:be:ff:00:10,openshift-worker-2,[2620:52:0:1305::10]
EOF

cat <<EOF > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

# Cluster Services - Network IPv4v6
172.16.100.3        api.ipv6.virtual.cluster.lab
172.16.100.3        api-int.ipv6.virtual.cluster.lab
#2620:52:0:1305::3  api.ipv6.virtual.cluster.lab
#2620:52:0:1305::3  api-int.ipv6.virtual.cluster.lab

172.16.100.2        console-openshift-console.apps.ipv6.virtual.cluster.lab
#2620:52:0:1305::2  console-openshift-console.apps.ipv6.virtual.cluster.lab

172.16.100.2        oauth-openshift.apps.ipv6.virtual.cluster.lab
#2620:52:0:1305::2  oauth-openshift.apps.ipv6.virtual.cluster.lab


# Cluster Nodes - Network IPv4v6
172.16.100.5        openshift-master-0.ipv6.virtual.cluster.lab
2620:52:0:1305::5   openshift-master-0.ipv6.virtual.cluster.lab

172.16.100.6        openshift-master-1.ipv6.virtual.cluster.lab
2620:52:0:1305::6   openshift-master-1.ipv6.virtual.cluster.lab

172.16.100.7        openshift-master-2.ipv6.virtual.cluster.lab
2620:52:0:1305::7   openshift-master-2.ipv6.virtual.cluster.lab

172.16.100.8        openshift-worker-0.ipv6.virtual.cluster.lab
2620:52:0:1305::8   openshift-worker-0.ipv6.virtual.cluster.lab

172.16.100.9        openshift-worker-1.ipv6.virtual.cluster.lab
2620:52:0:1305::9   openshift-worker-1.ipv6.virtual.cluster.lab

172.16.100.10       openshift-worker-2.ipv6.virtual.cluster.lab
2620:52:0:1305::10  openshift-worker-2.ipv6.virtual.cluster.lab
EOF

setenforce 0
clear > /opt/dnsmasq-ipv4v6/hosts.leases


# 3) Execute dnsmasq as systemd
printf "\n================================\n"
printf "| Execute dnsmasq as systemd |\n"
printf "================================\n\n"

cat <<EOF > /etc/systemd/system/dnsmasq-ipv4v6.service
[Unit]
Description=DNS server for Openshift 4 Virt clusters.
After=network.target
[Service]
User=root
Group=root
ExecStart=/usr/sbin/dnsmasq -k --conf-file=/opt/dnsmasq-ipv4v6/dnsmasq.conf
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable dnsmasq-ipv4v6 --now

systemctl restart dnsmasq-ipv4v6
