#!/bin/bash

QEMU_IMAGE=$(openshift-baremetal-install coreos print-stream-json | jq -r '.architectures.x86_64.artifacts.qemu.formats."qcow2.gz".disk.location')
OPENSTACK_IMAGE=$(openshift-baremetal-install coreos print-stream-json | jq -r '.architectures.x86_64.artifacts.openstack.formats."qcow2.gz".disk.location')

mkdir -pv /opt/httpd


# 1) Download OpenStack image for OCP Cluster nodes
printf "\n==================================================\n"
printf "| Download OpenStack image for OCP Cluster nodes | --> %s\n" "$(basename "${OPENSTACK_IMAGE}")"
printf "==================================================\n\n"

if [[ ! -f /opt/httpd/$(basename "${OPENSTACK_IMAGE}") ]]
then
  curl -Lk "${OPENSTACK_IMAGE}" -o /opt/httpd/"$(basename "${OPENSTACK_IMAGE}")"
fi


# 2) Download QEMU image for Bootstrap VM
printf "\n========================================\n"
printf "| Download QEMU image for Bootstrap VM | --> %s\n" "$(basename "${QEMU_IMAGE}")"
printf "========================================\n\n"

if [[ ! -f /opt/httpd/$(basename "${QEMU_IMAGE}") ]]
then
  curl -Lk "${QEMU_IMAGE}" -o /opt/httpd/"$(basename "${QEMU_IMAGE}")"
fi


# 3) Check downloaded images
printf "\n===========================\n"
printf "| Check downloaded images |\n"
printf "===========================\n\n"

podman exec -ti httpd ls -lah /var/www/html
