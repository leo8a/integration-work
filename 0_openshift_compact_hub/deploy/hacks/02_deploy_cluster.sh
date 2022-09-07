#!/bin/bash

ASSETS_DIR=/opt/assets


# 1) Deploy OpenShift Compact (3:0) Hub Cluster
printf "\n==============================================\n"
printf "| Deploy OpenShift Compact (3:0) Hub Cluster |\n"
printf "==============================================\n\n"

mkdir -pv /root/.kube

if [ ! -d /opt/"${OCP_CLUSTER_NAME}" ]; then
  rm -rf /opt/"${OCP_CLUSTER_NAME}" ; mkdir -pv /opt/"${OCP_CLUSTER_NAME}"/openshift
  cp ${ASSETS_DIR}/install-config.yaml /opt/"${OCP_CLUSTER_NAME}"/install-config.yaml

  openshift-baremetal-install --dir /opt/"${OCP_CLUSTER_NAME}" --log-level debug create manifests
  openshift-baremetal-install --dir /opt/"${OCP_CLUSTER_NAME}" --log-level debug create cluster

  cp /opt/"${OCP_CLUSTER_NAME}"/auth/kubeconfig /root/.kube/config
else
  echo "OpenShift Compact (3:0) Hub Cluster already deployed!"
fi


# 2) Create CS and ICSP for resources in local registry
printf "\n======================================================\n"
printf "| Create CS and ICSP for resources in local registry |\n"
printf "======================================================\n\n"

oc patch OperatorHub cluster --type json \
       -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

oc apply -f /opt/assets/CS/
oc apply -f /opt/assets/ICSP/
