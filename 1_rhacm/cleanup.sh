#!/bin/bash


function get_open_cluster_management_repo() {
  clean_open_cluster_management_repo
  git clone https://github.com/stolostron/deploy.git /opt/rhacm_deploy
}

function uninstall_acm() {
  cd /opt/rhacm_deploy || exit 1
  ./uninstall.sh   # .*[4-9]|10\.[3-9]\..*
}

function clean_open_cluster_management_repo() {
  rm -rf /opt/rhacm_deploy
}

function remove_lso() {
  oc delete localvolume --all --all-namespaces
  oc delete localvolumeset --all --all-namespaces
  oc delete localvolumediscovery --all --all-namespaces
#  oc delete pv ###
  oc delete project openshift-local-storage
}


# 1) Clone open-cluster-management project repo
printf "\n==============================================\n"
printf "| Clone open-cluster-management project repo |\n"
printf "==============================================\n\n"

get_open_cluster_management_repo


# 2) Uninstall Advanced Cluster Management (ACM) for Kubernetes
printf "\n==============================================================\n"
printf "| Uninstall Advanced Cluster Management (ACM) for Kubernetes |\n"
printf "==============================================================\n\n"

uninstall_acm


# 3) Clean open-cluster-management project repo
printf "\n==============================================\n"
printf "| Clean open-cluster-management project repo |\n"
printf "==============================================\n\n"

clean_open_cluster_management_repo


# 4) Uninstall Local Storage Operator (LSO)
printf "\n==========================================\n"
printf "| Uninstall Local Storage Operator (LSO) |\n"
printf "==========================================\n\n"
