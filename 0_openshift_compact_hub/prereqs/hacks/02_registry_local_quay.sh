#!/bin/bash


# 1) Install container-tools
printf "\n===========================\n"
printf "| Install container-tools |\n"
printf "===========================\n\n"

sudo dnf module install -y container-tools

grep -qxF '# podman aliases ' ~/.bashrc || echo -e "\n# podman aliases \nalias pd='podman'\nalias pds='podman ps'\nalias pdi='podman images'" | sudo tee -a /root/.bashrc
source /root/.bashrc


# 2) Get mirror-registry
printf "\n==============================\n"
printf "| Get ./mirror-registry tool |\n"
printf "==============================\n\n"

curl -s -L https://mirror.openshift.com/pub/openshift-v4/amd64/clients/mirror-registry/latest/mirror-registry.tar.gz | tar xvz -C /usr/bin
mirror-registry --version


# 3) Deploy disconnected registry
printf "\n================================\n"
printf "| Deploy disconnected registry |\n"
printf "================================\n\n"

if [[ ! -d /etc/quay-install ]]
then
  mirror-registry install \
                  --verbose \
                  --initUser init \
                  --initPassword adrogallop

  rm -rf pause.tar postgres.tar quay.tar redis.tar
  sudo cp /etc/quay-install/quay-rootCA/rootCA.pem /etc/pki/ca-trust/source/anchors/
  sudo update-ca-trust
fi


# 4) Check disconnected registry
printf "\n==============================\n"
printf "| Check disconnected registry |\n"
printf "==============================\n\n"

sudo podman pod ps
sudo podman login -u init -p "adrogallop" "$(hostname -f)":8443


# 5) Uninstall disconnected registry
# mirror-registry uninstall --autoApprove
