#!/usr/bin/env bash

echo <<EoM
  $. = Run on PC: provide a VM name@PE, will upload disk image.
EoM

export PATH=${PATH}:${HOME}
# Source Nutanix environment (PATH + aliases), then Workshop common routines + global variables
. /etc/profile.d/nutanix_env.sh
. common.lib.sh
. global.vars.sh
begin

Dependencies 'install' 'jq'

Determine_PE || log 'Error: cannot Determine_PE' && exit 13

#  CLUSTER_NAME=Specialty02
# MY_PE_HOST=$(nuclei cluster.get ${CLUSTER_NAME} format=json \
#   | jq .spec.resources.network.external_ip \
#   | tr -d \") # NuCLEI
if [[ -z "${1}" ]]; then
  VM_NAME=centos7-ml
else
  VM_NAME=${1}
fi

#nuclei vm.get ${VM_NAME} format=json \
#   | jq '.spec.resources.disk_list[] | select(.device_properties.device_type == "DISK") | .uuid' \
#   | tr -d \" # NuCLEI output example = logs/cb.json

log "Powering ${VM_NAME} off ..."
nuclei vm.update ${VM_NAME} power_state=OFF

VM_UUID=$(acli -H ${MY_PE_HOST} -o json vm.list \
  | jq '.data[] | select(.name == "'${VM_NAME}'") | .uuid' \
  | tr -d \") # acli output example = logs/cb2.pretty.json
if (( $? > 0 )) || [[ -z "${VM_UUID}" ]]; then
  log "Error: couldn't resolve VM_UUID: $?"
  exit 11
else
  log "VM_UUID: ${VM_UUID}"
fi

VMDISK_NFS_PATH=$(acli -H ${MY_PE_HOST} -o json vm.get ${VM_NAME} include_vmdisk_paths=true \
  | jq .data.\"${VM_UUID}\".config.disk_list[].vmdisk_nfs_path \
  | grep -v null | tr -d \") # leading /, acli output example = logs/vm.list.pretty.json
if (( $? > 0 )) || [[ -z "${VMDISK_NFS_PATH}" ]]; then
  log "Error: couldn't resolve VMDISK_NFS_PATH: $?"
  exit 12
else
  echo "VMDISK_NFS_PATH: nfs://${MY_PE_HOST}${VMDISK_NFS_PATH}"
fi

IMG=${VM_NAME}_$(date +%Y%m%d-%H:%M)
log "Image upload: ${IMG}..."
nuclei image.create name=${IMG} \
  description="${IMG} updated with centos password and cloud-init" \
  source_uri=nfs://${MY_PE_HOST}${VMDISK_NFS_PATH}

if (( $? != 0 )); then
  log "Warning: Image submission: $?."
  #exit 10
fi
log "NOTE: image.uuid = RUNNING, but takes a while to show up in:"
log "TODO: nuclei image.list, state = COMPLETE; image.list Name UUID State"

exit 0

NOTES:

This makes an arbitrary VM disk on a cluster available as a Disk image
to the AHV Image Service via Prism Central
(and presumably, available to all AHV clusters controlled by PC?).

The next step is to move images between clusters, but this is
https://jira.nutanix.com/browse/FEAT-2185 = AHV: Support OVF/OVA Import/Export
and interesting script work in the meantime, like this and:
- https://drt-it-github-prod-1.eng.nutanix.com/sandeep-cariapa/export-import-vms-AHV
- http://thephuck.com/disaster-recovery/backup-and-restore-a-vm-in-ahv/

In the meantime, because NFS and SFTP are interfaces into ADFS,
we can use either of two methods to move VM disk images between clusters:

1. Easiest option = Copy the raw, uncompressed VMDisk via NFS between clusters:
   - On the source AHV cluster with the VM+Disk, use Gear > Filesystem Whitelist
     to add the target AHV cluster:
     - PC (or PE) IP address and netmask: 255.255.255.0 should be sufficient.
     - nuclei cluster update $CLUSTER_NAME nfs_subnet_whitelist=
       - Comma separated list of subnets (of the form 'a.b.c.d/l.m.n.o') that are allowed to send NFS request
  - On the destination cluster, use PC: Explore > Images > Add Image button
    - Image Source: URL radio button
    - Use nfs://PE_ADDRESS/NFSpath
    - nuclei image...
  - Watch progress via tasks
2. Raw VMdisk image download and conversion to infrastructure artifact:
  - From the source cluster, download a VM disk via SFTP://PE:2222/NFSPATH
    using PC authentication (admin, etc.) or cluster lockdown SSH keys.
  - Convert the image to QCOW2
    - TODO: Dependencies('qemu')
    - qemu-img convert -c -p -f raw ./c7e11d23-5602-40b1-837e-229ac18270c6 -O qcow2 centos7-ml2.qcow2
      - man qemu-img # suggests a snapshot can be exported as well: -c = compress, -p = progress
      - can use nfs URLs for transport, formats support: ftp(s), http(s) URLs?
  - Upload to a object storage or web server
  - On the destination cluster, use PC: Explore > Images > Add Image button
  - Image Source: URL radio button
  - Use http URL
  - Watch progress via tasks
3. Possibly consider Packer to synthesize image artifact:
  - TODO: Andrew Nelson's blog http://virtual-hiking.blogspot.com/2015/10/using-packer-to-build-images-for.html
  - Jenkins job? Calm downloadable image index vs. AHV image macro?

# Research:
- My quest = https://jira.nutanix.com/browse/FEAT-5388

- https://portal.nutanix.com/#/page/docs/details?targetId=AHV-Admin-Guide-v55:ahv-upload-images-ndfs-windows-t.html
  - explains SFTP is prism auth
- discussion of iptables for SFTP:2222 access:
  - https://portal.nutanix.com/#/page/kbs/details?targetId=kA00e000000XevaCAC
  - how to access nutanix ports from different subnet.
    - https://portal.nutanix.com/#/page/kbs/details?targetId=kA0600000008TsmCAE
- Configure a Filesystem Whitelist
  - https://portal.nutanix.com/#/page/docs/details?targetId=Migration-Guide-AOS-v58:vmm-vm-migrate-whitelist-t.html#task_a5d_54d_d6
- Provide Read Access to a Nutanix Cluster
  - https://portal.nutanix.com/#/page/docs/details?targetId=Migration-Guide-AOS-v58:vmm-target-ahv-cluster-provide-read-access-t.html
- Overall VM+metadata move https://portal.nutanix.com/#/page/kbs/details?targetId=kA032000000TTqoCAG

versus image download:
- nuclei -output_format json image.get WindowsServer2016-Base.qcow2
- https://10.21.5.39:9440/api/nutanix/v3/images/9367da60-157d-4e7f-9adb-e8e83f8f23e0/file
- for PC, not PE
