#!/bin/bash
#
# Please configure according to your needs
#
function pc_remote_exec {
    sshpass -p nutanix/4u ssh -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null nutanix@10.21.${MY_HPOC_NUMBER}.39 "$@"
}
function pc_send_file {
    sshpass -p nutanix/4u scp -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null "$1" nutanix@10.21.${MY_HPOC_NUMBER}.39:/home/nutanix/"$1"
}

# Loging date format
#Never:0 Make logging format configurable
#MY_LOG_DATE='date +%Y-%m-%d %H:%M:%S'
# Script file name
MY_SCRIPT_NAME=`basename "$0"`
# Derive HPOC number from IP 3rd byte
#MY_CVM_IP=$(ip addr | grep inet | cut -d ' ' -f 6 | grep ^10.21 | head -n 1)
MY_CVM_IP=$(/sbin/ifconfig eth0 | grep 'inet ' | awk '{ print $2}')
array=(${MY_CVM_IP//./ })
MY_HPOC_NUMBER=${array[2]}
# HPOC Password (if commented, we assume we get that from environment)
#MY_PE_PASSWORD='nx2TechXXX!'
MY_SP_NAME='SP01'
MY_CONTAINER_NAME='Default'
MY_IMG_CONTAINER_NAME='Images'
MY_DOMAIN_FQDN='ntnxlab.local'
MY_DOMAIN_NAME='NTNXLAB'
MY_DOMAIN_USER='administrator@ntnxlab.local'
MY_DOMAIN_PASS='nutanix/4u'
MY_DOMAIN_ADMIN_GROUP='SSP Admins'
MY_DOMAIN_URL="ldaps://10.21.${MY_HPOC_NUMBER}.40/"
MY_PRIMARY_NET_NAME='Primary'
MY_PRIMARY_NET_VLAN='0'
MY_SECONDARY_NET_NAME='Secondary'
MY_SECONDARY_NET_VLAN="${MY_HPOC_NUMBER}1"
MY_PC_SRC_URL='http://10.21.249.53/pc-5.7.1-stable-prism_central.tar'
MY_PC_META_URL='http://10.21.249.53/pc-5.7.1-stable-prism_central_metadata.json'
MY_AFS_SRC_URL='http://10.21.250.221/images/ahv/techsummit/nutanix-afs-el7.3-release-afs-3.0.0.1-stable.qcow2'
MY_AFS_META_URL='http://10.21.250.221/images/ahv/techsummit/nutanix-afs-el7.3-release-afs-3.0.0.1-stable-metadata.json'

# From this point, we assume:
# IP Range: 10.21.${MY_HPOC_NUMBER}.0/25
# Gateway: 10.21.${MY_HPOC_NUMBER}.1
# DNS: 10.21.253.10,10.21.253.11
# Domain: nutanixdc.local
# DHCP Pool: 10.21.${MY_HPOC_NUMBER}.50 - 10.21.${MY_HPOC_NUMBER}.120
#
# DO NOT CHANGE ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING!!
#
# Source Nutanix environments (for PATH and other things)
source /etc/profile.d/nutanix_env.sh
# Logging function
function my_log {
    #echo `$MY_LOG_DATE`" $1"
    echo $(date "+%Y-%m-%d %H:%M:%S") $1
}
# Check if we got a password from environment or from the settings above, otherwise exit before doing anything
if [[ -z ${MY_PE_PASSWORD+x} ]]; then
    my_log "No password provided, exiting"
    exit -1
fi
my_log "My PID is $$"
my_log "Installing sshpass"
sudo rpm -ivh https://fr2.rpmfind.net/linux/epel/7/x86_64/Packages/s/sshpass-1.06-1.el7.x86_64.rpm
# Configure SMTP
my_log "Configure SMTP"
ncli cluster set-smtp-server address=nutanix-com.mail.protection.outlook.com from-email-address=cluster@nutanix.com port=25
# Configure NTP
my_log "Configure NTP"
ncli cluster add-to-ntp-servers servers=0.us.pool.ntp.org,1.us.pool.ntp.org,2.us.pool.ntp.org,3.us.pool.ntp.org
# Rename default storage container to MY_CONTAINER_NAME
my_log "Rename default container to ${MY_CONTAINER_NAME}"
default_container=$(ncli container ls | grep -P '^(?!.*VStore Name).*Name' | cut -d ':' -f 2 | sed s/' '//g | grep '^default-container-')
ncli container edit name="${default_container}" new-name="${MY_CONTAINER_NAME}"
# Rename default storage pool to MY_SP_NAME
my_log "Rename default storage pool to ${MY_SP_NAME}"
default_sp=$(ncli storagepool ls | grep 'Name' | cut -d ':' -f 2 | sed s/' '//g)
ncli sp edit name="${default_sp}" new-name="${MY_SP_NAME}"
# Check if there is a container named MY_IMG_CONTAINER_NAME, if not create one
my_log "Check if there is a container named ${MY_IMG_CONTAINER_NAME}, if not create one"
(ncli container ls | grep -P '^(?!.*VStore Name).*Name' | cut -d ':' -f 2 | sed s/' '//g | grep "^${MY_IMG_CONTAINER_NAME}" 2>&1 > /dev/null) \
    && echo "Container ${MY_IMG_CONTAINER_NAME} already exists" \
    || ncli container create name="${MY_IMG_CONTAINER_NAME}" sp-name="${MY_SP_NAME}"
# Set external IP address:
#ncli cluster edit-params external-ip-address=10.21.${MY_HPOC_NUMBER}.37
# Set Data Services IP address:
my_log "Set Data Services IP address to 10.21.${MY_HPOC_NUMBER}.38"
ncli cluster edit-params external-data-services-ip-address=10.21.${MY_HPOC_NUMBER}.38

# Importing images
MY_IMAGE="AutoDC"
retries=1
my_log "Importing ${MY_IMAGE} image"
until [[ $(acli image.create ${MY_IMAGE} container="${MY_IMG_CONTAINER_NAME}" image_type=kDiskImage source_url=http://10.21.250.221/images/ahv/techsummit/AutoDC.qcow2 wait=true) =~ "complete" ]]; do
  let retries++
  if [ $retries -gt 5 ]; then
    my_log "${MY_IMAGE} failed to upload after 5 attempts. This cluster may require manual remediation."
    acli vm.create STAGING-FAILED-${MY_IMAGE}
    break
  fi
  my_log "acli image.create ${MY_IMAGE} FAILED. Retrying upload (${retries} of 5)..."
  sleep 5
done

MY_IMAGE="CentOS"
retries=1
my_log "Importing ${MY_IMAGE} image"
until [[ $(acli image.create ${MY_IMAGE} container="${MY_IMG_CONTAINER_NAME}" image_type=kDiskImage source_url=http://10.21.250.221/images/ahv/techsummit/CentOS7-04282018.qcow2 wait=true) =~ "complete" ]]; do
  let retries++
  if [ $retries -gt 5 ]; then
    my_log "${MY_IMAGE} failed to upload after 5 attempts. This cluster may require manual remediation."
    acli vm.create STAGING-FAILED-${MY_IMAGE}
    break
  fi
  my_log "acli image.create ${MY_IMAGE} FAILED. Retrying upload (${retries} of 5)..."
  sleep 5
done

MY_IMAGE="Windows2012"
retries=1
my_log "Importing ${MY_IMAGE} image"
until [[ $(acli image.create ${MY_IMAGE} container="${MY_IMG_CONTAINER_NAME}" image_type=kDiskImage source_url=http://10.21.250.221/images/ahv/techsummit/Windows2012R2-04282018.qcow2 wait=true) =~ "complete" ]]; do
  let retries++
  if [ $retries -gt 5 ]; then
    my_log "${MY_IMAGE} failed to upload after 5 attempts. This cluster may require manual remediation."
    acli vm.create STAGING-FAILED-${MY_IMAGE}
    break
  fi
  my_log "acli image.create ${MY_IMAGE} FAILED. Retrying upload (${retries} of 5)..."
  sleep 5
done

MY_IMAGE="Windows10"
retries=1
my_log "Importing ${MY_IMAGE} image"
until [[ $(acli image.create ${MY_IMAGE} container="${MY_IMG_CONTAINER_NAME}" image_type=kDiskImage source_url=http://10.21.250.221/images/ahv/techsummit/Windows10-1709-04282018.qcow2 wait=true) =~ "complete" ]]; do
  let retries++
  if [ $retries -gt 5 ]; then
    my_log "${MY_IMAGE} failed to upload after 5 attempts. This cluster may require manual remediation."
    acli vm.create STAGING-FAILED-${MY_IMAGE}
    break
  fi
  my_log "acli image.create ${MY_IMAGE} FAILED. Retrying upload (${retries} of 5)..."
  sleep 5
done

MY_IMAGE="XenDesktop-7.15.iso"
retries=1
my_log "Importing ${MY_IMAGE} image"
until [[ $(acli image.create ${MY_IMAGE} container="${MY_IMG_CONTAINER_NAME}" image_type=kIsoImage source_url=http://10.21.250.221/images/ahv/techsummit/XD715.iso wait=true) =~ "complete" ]]; do
  let retries++
  if [ $retries -gt 5 ]; then
    my_log "${MY_IMAGE} failed to upload after 5 attempts. This cluster may require manual remediation."
    acli vm.create STAGING-FAILED-${MY_IMAGE}
    break
  fi
  my_log "acli image.create ${MY_IMAGE} FAILED. Retrying upload (${retries} of 5)..."
  sleep 5
done

# Remove existing VMs, if any
my_log "Removing \"Windows 2012\" VM if it exists"
acli -y vm.delete Windows\ 2012\ VM delete_snapshots=true
my_log "Removing \"Windows 10\" VM if it exists"
acli -y vm.delete Windows\ 10\ VM delete_snapshots=true
my_log "Removing \"CentOS\" VM if it exists"
acli -y vm.delete CentOS\ VM delete_snapshots=true

# Remove Rx-Automation-Network network
my_log "Removing \"Rx-Automation-Network\" Network if it exists"
acli -y net.delete Rx-Automation-Network

# Create primary network
my_log "Create primary network:"
my_log "Name: ${MY_PRIMARY_NET_NAME}"
my_log "VLAN: ${MY_PRIMARY_NET_VLAN}"
my_log "Subnet: 10.21.${MY_HPOC_NUMBER}.1/25"
my_log "Domain: ${MY_DOMAIN_NAME}"
my_log "Pool: 10.21.${MY_HPOC_NUMBER}.50 to 10.21.${MY_HPOC_NUMBER}.125"
acli net.create ${MY_PRIMARY_NET_NAME} vlan=${MY_PRIMARY_NET_VLAN} ip_config=10.21.${MY_HPOC_NUMBER}.1/25
acli net.update_dhcp_dns ${MY_PRIMARY_NET_NAME} servers=10.21.${MY_HPOC_NUMBER}.40,10.21.253.10 domains=${MY_DOMAIN_NAME}
acli net.add_dhcp_pool ${MY_PRIMARY_NET_NAME} start=10.21.${MY_HPOC_NUMBER}.50 end=10.21.${MY_HPOC_NUMBER}.125

# Create secondary network
if [[ ${MY_SECONDARY_NET_NAME} ]]; then
  my_log "Create secondary network:"
  my_log "Name: ${MY_SECONDARY_NET_NAME}"
  my_log "VLAN: ${MY_SECONDARY_NET_VLAN}"
  my_log "Subnet: 10.21.${MY_HPOC_NUMBER}.129/25"
  my_log "Domain: ${MY_DOMAIN_NAME}"
  my_log "Pool: 10.21.${MY_HPOC_NUMBER}.132 to 10.21.${MY_HPOC_NUMBER}.253"
  acli net.create ${MY_SECONDARY_NET_NAME} vlan=${MY_SECONDARY_NET_VLAN} ip_config=10.21.${MY_HPOC_NUMBER}.129/25
  acli net.update_dhcp_dns ${MY_SECONDARY_NET_NAME} servers=10.21.${MY_HPOC_NUMBER}.40,10.21.253.10 domains=${MY_DOMAIN_NAME}
  acli net.add_dhcp_pool ${MY_SECONDARY_NET_NAME} start=10.21.${MY_HPOC_NUMBER}.132 end=10.21.${MY_HPOC_NUMBER}.253
fi

# Create AutoDC & power on
my_log "Create DC VM based on AutoDC image"
acli vm.create DC num_vcpus=2 num_cores_per_vcpu=1 memory=4G
acli vm.disk_create DC cdrom=true empty=true
acli vm.disk_create DC clone_from_image=AutoDC
acli vm.nic_create DC network=${MY_PRIMARY_NET_NAME} ip=10.21.${MY_HPOC_NUMBER}.40
my_log "Power on DC VM"
acli vm.on DC

# Need to wait for AutoDC to be up (30?60secs?)
my_log "Waiting 60sec to give DC VM time to start"
sleep 60

# Configure PE external authentication
my_log "Configure PE external authentication"
ncli authconfig add-directory directory-type=ACTIVE_DIRECTORY connection-type=LDAP directory-url="${MY_DOMAIN_URL}" domain="${MY_DOMAIN_FQDN}" name="${MY_DOMAIN_NAME}" service-account-username="${MY_DOMAIN_USER}" service-account-password="${MY_DOMAIN_PASS}"

# Configure PE role mapping
my_log "Configure PE role mapping"
ncli authconfig add-role-mapping role=ROLE_CLUSTER_ADMIN entity-type=group name="${MY_DOMAIN_NAME}" entity-values="${MY_DOMAIN_ADMIN_GROUP}"

# Reverse Lookup Zone
my_log "Creating Reverse Lookup Zone on DC VM"
sshpass -p nutanix/4u ssh -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null \
root@10.21.${MY_HPOC_NUMBER}.40 "samba-tool dns zonecreate dc1 ${MY_HPOC_NUMBER}.21.10.in-addr.arpa; service samba-ad-dc restart"

# Create custom OUs
sshpass -p nutanix/4u ssh -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null \
root@10.21.${MY_HPOC_NUMBER}.40 "apt install ldb-tools -y -q"

sshpass -p nutanix/4u ssh -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null \
root@10.21.${MY_HPOC_NUMBER}.40 "cat << EOF > ous.ldif
dn: OU=Non-PersistentDesktop,DC=NTNXLAB,DC=local
changetype: add
objectClass: top
objectClass: organizationalunit
description: Non-Persistent Desktop OU

dn: OU=PersistentDesktop,DC=NTNXLAB,DC=local
changetype: add
objectClass: top
objectClass: organizationalunit
description: Persistent Desktop OU

dn: OU=XenAppServer,DC=NTNXLAB,DC=local
changetype: add
objectClass: top
objectClass: organizationalunit
description: XenApp Server OU
EOF"

sshpass -p nutanix/4u ssh -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null \
root@10.21.${MY_HPOC_NUMBER}.40 "ldbmodify  -H /var/lib/samba/private/sam.ldb ous.ldif; service samba-ad-dc restart"

# Provision local Prism account for XD MCS Plugin
my_log "Create PE user account xd for MCS Plugin"
ncli user create user-name=xd user-password=nutanix/4u first-name=XenDesktop last-name=Service email-id=no-reply@nutanix.com
ncli user grant-cluster-admin-role user-name=xd

# Get UUID from cluster
my_log "Get UUIDs from cluster:"
MY_NET_UUID=$(acli net.get ${MY_PRIMARY_NET_NAME} | grep "uuid" | cut -f 2 -d ':' | xargs)
my_log "${MY_PRIMARY_NET_NAME} UUID is ${MY_NET_UUID}"
MY_CONTAINER_UUID=$(ncli container ls name=${MY_CONTAINER_NAME} | grep Uuid | grep -v Pool | cut -f 2 -d ':' | xargs)
my_log "${MY_CONTAINER_NAME} UUID is ${MY_CONTAINER_UUID}"

# Validate EULA on PE
my_log "Validate EULA on PE"
curl -u admin:${MY_PE_PASSWORD} -k -H 'Content-Type: application/json' -X POST \
  https://127.0.0.1:9440/PrismGateway/services/rest/v1/eulas/accept \
  -d '{
    "username": "SE",
    "companyName": "NTNX",
    "jobTitle": "SE"
}'

# Disable Pulse in PE
my_log "Disable Pulse in PE"
curl -u admin:${MY_PE_PASSWORD} -k -H 'Content-Type: application/json' -X PUT \
  https://127.0.0.1:9440/PrismGateway/services/rest/v1/pulse \
  -d '{
    "defaultNutanixEmail": null,
    "emailContactList": null,
    "enable": false,
    "enableDefaultNutanixEmail": false,
    "isPulsePromptNeeded": false,
    "nosVersion": null,
    "remindLater": null,
    "verbosityType": null
}'

# AFS Download
my_log "Download AFS image from ${MY_AFS_SRC_URL}"
wget -nv ${MY_AFS_SRC_URL}
my_log "Download AFS metadata JSON from ${MY_AFS_META_URL}"
wget -nv ${MY_AFS_META_URL}

# Staging AFS
my_log "Stage AFS"
ncli software upload file-path=/home/nutanix/${MY_AFS_SRC_URL##*/} meta-file-path=/home/nutanix/${MY_AFS_META_URL##*/} software-type=FILE_SERVER

# Freeing up space
my_log "Delete AFS sources to free some space"
rm ${MY_AFS_SRC_URL##*/} ${MY_AFS_META_URL##*/}

# Prism Central Download
my_log "Download PC tarball from ${MY_PC_SRC_URL}"
wget -nv ${MY_PC_SRC_URL}
my_log "Download PC metadata JSON from ${MY_PC_META_URL}"
wget -nv ${MY_PC_META_URL}

# Staging Prism Central
my_log "Stage Prism Central"
ncli software upload file-path=/home/nutanix/${MY_PC_SRC_URL##*/} meta-file-path=/home/nutanix/${MY_PC_META_URL##*/} software-type=PRISM_CENTRAL_DEPLOY

# Freeing up space
my_log "Delete PC sources to free some space"
rm ${MY_PC_SRC_URL##*/} ${MY_PC_META_URL##*/}

# Deploy Prism Central
my_log "Deploy Prism Central"
# TODO:110 Parameterize DNS Servers & add secondary
MY_DEPLOY_BODY=$(cat <<EOF
{
  "resources": {
      "should_auto_register":true,
      "version":"5.7.1",
      "pc_vm_list":[{
          "data_disk_size_bytes":536870912000,
          "nic_list":[{
              "network_configuration":{
                  "subnet_mask":"255.255.255.128",
                  "network_uuid":"${MY_NET_UUID}",
                  "default_gateway":"10.21.${MY_HPOC_NUMBER}.1"
              },
              "ip_list":["10.21.${MY_HPOC_NUMBER}.39"]
          }],
          "dns_server_ip_list":["10.21.${MY_HPOC_NUMBER}.40"],
          "container_uuid":"${MY_CONTAINER_UUID}",
          "num_sockets":4,
          "memory_size_bytes":17179869184,
          "vm_name":"PC"
      }]
  }
}
EOF
)
curl -u admin:${MY_PE_PASSWORD} -k -H 'Content-Type: application/json' -X POST https://127.0.0.1:9440/api/nutanix/v3/prism_central -d "${MY_DEPLOY_BODY}"
my_log "Waiting for PC deployment to complete (Sleeping 15m)"
sleep 900
my_log "Sending PC configuration script"
pc_send_file stage_citrixhow_pc.sh

# Execute that file asynchroneously remotely (script keeps running on CVM in the background)
my_log "Launching PC configuration script"
pc_remote_exec "MY_PE_PASSWORD=${MY_PE_PASSWORD} nohup bash /home/nutanix/stage_citrixhow_pc.sh >> pcconfig.log 2>&1 &"
my_log "Removing sshpass"
sudo rpm -e sshpass
my_log "PE Configuration complete"
