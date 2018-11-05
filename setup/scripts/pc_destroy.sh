#!/usr/bin/env bash

function pe_unregister {
  local _cluster_uuid
  local      _pc_uuid
  local           _vm
  # https://portal.nutanix.com/kb/4944

  # PE:
  cluster status # check
  ncli -h true multicluster remove-from-multicluster \
    external-ip-address-or-svm-ips=${MY_PC_HOST} \
    username=${PRISM_ADMIN} password=${MY_PE_PASSWORD} force=true
    # Error: This cluster was never added to Prism Central
  ncli multicluster get-cluster-state # check for none
  _cluster_uuid=$(ncli cluster info | grep -i uuid | awk -F: '{print $2}' | tr -d '[:space:]')

  exit 0
  # PC: remote_exec 'PC'
  chmod u+x /home/nutanix/bin/unregistration_cleanup.py \
  && python /home/nutanix/bin/unregistration_cleanup.py ${_cluster_uuid}
  # Uuid of current cluster cannot be passed to cleanup
  _pc_uuid=$(cluster info) # no such command!
  # PE:
  chmod u+x /home/nutanix/bin/unregistration_cleanup.py \
  && python /home/nutanix/bin/unregistration_cleanup.py ${_pc_uuid}

  # Troubleshooting
  cat ~/data/logs/unregistration_cleanup.log

  for _vm in `acli -o json vm.list | ~/jq -r '.data[] | select(.name | contains("Prism Central")) | .uuid'`; do
    log "PC vm.uuid=${_vm}"
    acli vm.off ${_vm} && acli -y vm.delete ${_vm}
  done
}

# Source Nutanix environment (PATH + aliases), then Workshop common routines + global variables
. /etc/profile.d/nutanix_env.sh
. common.lib.sh
. global.vars.sh
begin

    MY_PC_HOST=10.21.43.37
MY_PE_PASSWORD=nx2Tech381!
   PRISM_ADMIN=admin

pe_unregister

finish
