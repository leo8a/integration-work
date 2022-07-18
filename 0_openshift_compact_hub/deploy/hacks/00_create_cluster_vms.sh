#!/bin/bash

VIRT_NIC="networkipv4v6"


kcli create vm -P start=False -P memory=32000 \
                              -P numcpus=16 \
                              -P disks='[200,200,50,50,20,20,20]' \
                              -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:05\"}"] \
                              "${OCP_CLUSTER_NAME}"-master0

kcli create vm -P start=False -P memory=32000 \
                              -P numcpus=16 \
                              -P disks='[200,200,50,50,20,20,20]' \
                              -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:06\"}"] \
                              "${OCP_CLUSTER_NAME}"-master1

kcli create vm -P start=False -P memory=32000 \
                              -P numcpus=16 \
                              -P disks='[200,200,50,50,20,20,20]' \
                              -P nets=["{\"name\":\"${VIRT_NIC}\",\"nic\":\"ens3\",\"mac\":\"de:ad:be:ff:00:07\"}"] \
                              "${OCP_CLUSTER_NAME}"-master2
