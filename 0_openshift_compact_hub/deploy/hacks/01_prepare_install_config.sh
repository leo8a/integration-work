#!/bin/bash

ASSETS_DIR=/opt/assets
INSTALL_CONFIG_FILE=${ASSETS_DIR}/install-config.yaml

OPENSTACK_IMAGE=$(openshift-baremetal-install coreos print-stream-json | jq -r '.architectures.x86_64.artifacts.openstack.formats."qcow2.gz".disk.location')
OPENSTACK_IMAGE_SHA256=$(openshift-baremetal-install coreos print-stream-json | jq -r '.architectures.x86_64.artifacts.openstack.formats."qcow2.gz".disk.sha256')

QEMU_IMAGE=$(openshift-baremetal-install coreos print-stream-json | jq -r '.architectures.x86_64.artifacts.qemu.formats."qcow2.gz".disk.location')
QEMU_IMAGE_UNCOMPRESSED_SHA256=$(openshift-baremetal-install coreos print-stream-json | jq -r '.architectures.x86_64.artifacts.qemu.formats."qcow2.gz".disk."uncompressed-sha256"')


sudo cp -f ./0_openshift_compact_hub/deploy/templates/install-config-template.yaml ${ASSETS_DIR}/install-config.yaml

# Get redfish endpoints for every node
for node in master0 master1 master2
do
  VMID=$(kcli info vm "${OCP_CLUSTER_NAME}"-${node} -f id -v)
  sed -i "s/${node}id/${VMID}/" "${INSTALL_CONFIG_FILE}"
done

sed -i "s/QEMUIMAGE/$(basename "${QEMU_IMAGE}")?sha256=${QEMU_IMAGE_UNCOMPRESSED_SHA256}/" "${INSTALL_CONFIG_FILE}"
sed -i "s/OSTACKIMAGE/$(basename "${OPENSTACK_IMAGE}")?sha256=${OPENSTACK_IMAGE_SHA256}/" "${INSTALL_CONFIG_FILE}"

sed -i "s/REGISTRYHOSTNAME/$(hostname -f)/" "${INSTALL_CONFIG_FILE}"
sed -i "s|SSHPUBKEY|$(cat ~/.ssh/id_rsa.pub)|" "${INSTALL_CONFIG_FILE}"

sed -i '/REGISTRYCA/e cat /etc/quay-install/quay-rootCA/rootCA.pem | sed "s/^/  /"' "${INSTALL_CONFIG_FILE}"
sed -i '/REGISTRYCA/d' "${INSTALL_CONFIG_FILE}"
podman login "$(hostname -f)":8443 -u init -p "adrogallop" --authfile /tmp/tempauth &> /dev/null
sed -i "s|PULLSECRET|$(jq '.' -c < /tmp/tempauth)|" "${INSTALL_CONFIG_FILE}"
rm -rf /tmp/tempauth
