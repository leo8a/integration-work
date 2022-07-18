#!/bin/bash


# 1) Install RaDvD and NTP services
printf "\n==================================\n"
printf "| Install RaDvD and NTP services |\n"
printf "==================================\n\n"

dnf install -y radvd chrony


# 2) Configure RaDvD and NTP services
printf "\n===================================\n"
printf "| Configure RaDvD and NTP services |\n"
printf "===================================\n\n"

cat <<EOF > /etc/radvd.conf
# Docs here: https://linux.die.net/man/5/radvd.conf
interface networkipv4v6
{
  # When set, hosts use the administered (stateful) protocol for address autoconfiguration in addition to any addresses
  # autoconfigured using stateless address autoconfiguration. The use of this flag is described in RFC 4862.
  AdvManagedFlag on;

  # A flag indicating whether or not the router sends periodic router advertisements and responds to router solicitations.
  # It needs to be on to enable advertisement on this interface.
  AdvSendAdvert on;

  # The minimum time allowed between sending unsolicited multicast router advertisements from the interface, in seconds.
  MinRtrAdvInterval 30;

  # The maximum time allowed between sending unsolicited multicast router advertisements from the interface, in seconds.
  MaxRtrAdvInterval 100;

  # The lifetime associated with the default router in units of seconds.
  # A lifetime of 0 indicates that the router is not a default router and should not appear on the default router list.
  AdvDefaultLifetime 9000;

  prefix 2620:52:0:1305::/64
  {
    # Indicates that this prefix can be used for on-link determination.
    AdvOnLink on;

    # Indicates that this prefix can be used for autonomous address configuration as specified in RFC 4862.
    AdvAutonomous on;

    # Indicates that the address of interface is sent instead of network prefix.
    AdvRouterAddr on;
  };
  route ::/0 {
    # The lifetime associated with the route in units of seconds.
    AdvRouteLifetime 9000;

    # The preference associated with the default router, as either "low", "medium", or "high".
    AdvRoutePreference low;

    # Upon shutdown, announce this route with a zero second lifetime.
    RemoveRoute on;
  };
};
EOF

cat <<EOF > /etc/chrony.conf
server clock.corp.redhat.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
bindcmdaddress ::
allow 192.168.123.0/24
allow 192.168.124.0/24
allow 172.16.100.0/24
allow 2620:52:0:1305::0/64
EOF


# 3) Start & Enable RaDvD and NTP services
printf "\n=========================================\n"
printf "| Start & Enable RaDvD and NTP services |\n"
printf "=========================================\n\n"

systemctl daemon-reload

systemctl enable radvd --now
systemctl enable chronyd --now

systemctl status radvd
systemctl status chronyd
