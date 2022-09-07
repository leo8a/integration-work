#!/bin/bash


function tear_down_cluster_vms() {
  kcli delete -y vm "${OCP_CLUSTER_NAME}"-master0 "${OCP_CLUSTER_NAME}"-master1 "${OCP_CLUSTER_NAME}"-master2
  BOOTSTRAP=$(kcli list vm | grep "ipv6-.*bootstrap" | awk -F "|" '{print $2}' | tr -d " " )
  if [[ ${BOOTSTRAP} != "" ]]
  then
    kcli delete vm "${BOOTSTRAP}" -y
  fi
  rm -rf /opt/"${OCP_CLUSTER_NAME}" \
         /var/lib/libvirt/images/*
}

function tear_down_registry() {
  mirror-registry uninstall --autoApprove
  systemctl disable quay_haproxy --now
  rm -rf /etc/quay-install \
         /usr/bin/execution-environment.tar /usr/bin/mirror-registry \
         /usr/lib/systemd/system/quay_haproxy.service
  systemctl daemon-reload

  podman rmi -a
  podman system prune -f
}

function tear_down_httpd() {
  systemctl disable podman-httpd --now
  rm -rf /opt/httpd \
         /etc/systemd/system/podman-httpd.service
  systemctl daemon-reload
}

function tear_down_dns_dhcp_ntp() {
  systemctl disable chronyd --now
  systemctl disable radvd --now
  systemctl disable dnsmasq-ipv4v6 --now
  rm -rf /etc/chrony.conf \
         /etc/radvd.conf \
         /opt/dnsmasq-ipv4v6 /etc/systemd/system/dnsmasq-ipv4v6.service
  systemctl daemon-reload
}


# 1) Tear down cluster VMs
printf "\n=========================\n"
printf "| Tear down cluster VMs |\n"
printf "=========================\n\n"

tear_down_cluster_vms


# 2) Tear down HTTPD server
printf "\n==========================\n"
printf "| Tear down HTTPD server |\n"
printf "==========================\n\n"

tear_down_httpd


# 3) Tear down Quay registry
printf "\n===========================\n"
printf "| Tear down Quay registry |\n"
printf "===========================\n\n"

tear_down_registry


# 4) Tear down DNS, DHCP, and NTP servers
printf "\n========================================\n"
printf "| Tear down DNS, DHCP, and NTP servers |\n"
printf "========================================\n\n"

tear_down_dns_dhcp_ntp
