#!/usr/bin/env bash

ASSETS_DIR=/opt/assets


# 1) Get oc-mirror tool
printf "\n========================\n"
printf "| Get ./oc-mirror tool |\n"
printf "========================\n\n"

curl -s -L https://mirror.openshift.com/pub/openshift-v4/amd64/clients/ocp-dev-preview/pre-release/oc-mirror.tar.gz | tar xvz -C /usr/bin
chmod +x /usr/bin/oc-mirror
oc-mirror version


# 2) Mirror OLM catalog images
printf "\n=============================\n"
printf "| Mirror OLM catalog images |\n"
printf "=============================\n\n"

rm -rvf ${ASSETS_DIR}/CS ; mkdir -pv ${ASSETS_DIR}/CS ${ASSETS_DIR}/ICSP
sudo cp -v "${LOCAL_SECRET_JSON}" "${XDG_RUNTIME_DIR}"/containers/auth.json

cat << EOF > ${ASSETS_DIR}/ISC/99-operators-mirror.yaml
apiVersion: mirror.openshift.io/v1alpha2
kind: ImageSetConfiguration
storageConfig:
  registry:
    imageURL: $(hostname -f):8443/olm

mirror:
  operators:
    - catalog: registry.redhat.io/redhat/redhat-operator-index:v4.10
      full: true
      packages:
        - name: advanced-cluster-management
          channels:
            - name: 'release-2.5'
            - name: 'release-2.6'
        - name: multicluster-engine
          channels:
            - name: 'stable-2.0'
            - name: 'stable-2.1'
        - name: ansible-automation-platform-operator
          channels:
            - name: 'stable-2.2-cluster-scoped'
        - name: openshift-gitops-operator
          channels:
            - name: 'latest'
        - name: odf-lvm-operator
          channels:
            - name: 'stable-4.10'
        - name: performance-addon-operator
          channels:
            - name: '4.10'
        - name: ptp-operator
          channels:
            - name: 'stable'
        - name: sriov-network-operator
          channels:
            - name: 'stable'
        - name: cluster-logging
          channels:
            - name: 'stable'
        - name: ocs-operator
          channels:
            - name: 'stable-4.10'
        - name: local-storage-operator
          channels:
            - name: 'stable'

    - catalog: registry.redhat.io/redhat/certified-operator-index:v4.10
      full: true
      packages:
        - name: sriov-fec
          channels:
            - name: 'stable'

    - catalog: registry.redhat.io/redhat/community-operator-index:v4.10
      full: true
      packages:
        - name: hive-operator
          channels:
            - name: 'alpha'
EOF

oc-mirror --config ${ASSETS_DIR}/ISC/99-operators-mirror.yaml \
          --max-per-registry 3 \
          docker://"$(hostname -f)":8443/olm


# 3) Clean up all temporal artifacts
printf "\n===================================\n"
printf "| Clean up all temporal artifacts |\n"
printf "===================================\n\n"

sudo cp -v ./oc-mirror-workspace/results-*/catalogSource-* ${ASSETS_DIR}/CS
sudo cp -v ./oc-mirror-workspace/results-*/imageContentSourcePolicy.yaml ${ASSETS_DIR}/ICSP/99-operators-mirror.yaml

rm -rfv oc-mirror-workspace
