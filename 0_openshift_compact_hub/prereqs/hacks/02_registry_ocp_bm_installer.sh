#!/bin/bash


# 1) Install oc tool
printf "\n===================\n"
printf "| Install oc tool | --> latest binaries\n"
printf "===================\n\n"

curl -s -L https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/openshift-client-linux.tar.gz | tar xvz -C /usr/bin

oc completion bash >> /etc/bash_completion.d/oc_completion
source /etc/bash_completion.d/oc_completion


# 2) Install openshift-baremetal-install tool
printf "\n============================================\n"
printf "| Install openshift-baremetal-install tool | --> %s\n" "${OCP_RELEASE_VERSION}"
printf "============================================\n\n"

# This needs to happen from the mirrored release
oc adm release extract --registry-config "$LOCAL_SECRET_JSON" \
                       --command=openshift-baremetal-install \
                       --to /usr/bin "$(hostname -f)":8443/ocp4/openshift/release-images:"${OCP_RELEASE_VERSION}"-x86_64

openshift-baremetal-install version
