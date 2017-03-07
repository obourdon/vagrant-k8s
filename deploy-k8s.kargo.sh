#!/bin/bash

set -xe

export CUSTOM_YAML="${CUSTOM_YAML:-custom.yaml}"

export INVENTORY="${INVENTORY:-nodes_to_inv.py}"

export K8S_NODES_FILE="${K8S_NODES_FILE:-nodes}"

export KARGO_GROUP_VARS="${KARGO_GROUP_VARS:-~/kargo/inventory/group_vars/all.yml}"

echo "Installing requirements on nodes..."
export ANSIBLE_LOG_PATH="/var/log/ansible_bootstrap.log"
ansible-playbook -i $INVENTORY playbooks/bootstrap-nodes.yaml

echo "Running deployment..."
export ANSIBLE_LOG_PATH="/var/log/kargo.log"
ansible-playbook -i $INVENTORY ~/kargo/cluster.yml -e @${CUSTOM_YAML}
deploy_res=$?

if [ "$deploy_res" -eq "0" ]; then
  echo "Setting up resolv.conf ..."
  export ANSIBLE_LOG_PATH="/var/log/ansible_resolv.log"
  ansible-playbook -i $INVENTORY playbooks/resolv_conf.yaml
fi
