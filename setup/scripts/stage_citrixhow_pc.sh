#!/bin/bash

#MY_PC_UPGRADE_URL='http://10.21.250.221/images/ahv/techsummit/nutanix_installer_package_pc-release-euphrates-5.5.0.6-stable-14bd63735db09b1c9babdaaf48d062723137fc46.tar.gz'

# Script file name
MY_SCRIPT_NAME=`basename "$0"`

# Source Nutanix environments (for PATH and other things)
. /etc/profile.d/nutanix_env.sh
. common.lib.sh # source common routines
Dependencies 'install';

# Derive HPOC number from IP 3rd byte
#MY_CVM_IP=$(ip addr | grep inet | cut -d ' ' -f 6 | grep ^10.21 | head -n 1)
     MY_CVM_IP=$(/sbin/ifconfig eth0 | grep 'inet ' | awk '{ print $2}')
         array=(${MY_CVM_IP//./ })
MY_HPOC_NUMBER=${array[2]}

CURL_OPTS="${CURL_OPTS} --user admin:${MY_PE_PASSWORD}" #common.lib.sh initialized
#CURL_OPTS="${CURL_OPTS} --verbose"

# Set Prism Central Password to Prism Element Password
my_log "Setting PC password to PE password"
ncli user reset-password user-name="admin" password="${MY_PE_PASSWORD}"

# Add NTP Server\
my_log "Configure NTP on PC"
ncli cluster add-to-ntp-servers servers=0.us.pool.ntp.org,1.us.pool.ntp.org,2.us.pool.ntp.org,3.us.pool.ntp.org

# Accept Prism Central EULA
my_log "Validate EULA on PC"
curl ${CURL_OPTS} \
  https://10.21.${MY_HPOC_NUMBER}.39:9440/PrismGateway/services/rest/v1/eulas/accept \
  -d '{
    "username": "SE",
    "companyName": "NTNX",
    "jobTitle": "SE"
}'

# Disable Prism Central Pulse
my_log "Disable Pulse on PC"
curl ${CURL_OPTS} -X PUT \
  https://10.21.${MY_HPOC_NUMBER}.39:9440/PrismGateway/services/rest/v1/pulse \
  -d '{
    "emailContactList":null,
    "enable":false,
    "verbosityType":null,
    "enableDefaultNutanixEmail":false,
    "defaultNutanixEmail":null,
    "nosVersion":null,
    "isPulsePromptNeeded":false,
    "remindLater":null
}'

# Prism Central upgrade
#my_log "Download PC upgrade image: ${MY_PC_UPGRADE_URL##*/}"
#wget -nv ${MY_PC_UPGRADE_URL}

#my_log "Prepare PC upgrade image"
#tar -xzf ${MY_PC_UPGRADE_URL##*/}
#rm ${MY_PC_UPGRADE_URL##*/}

#my_log "Upgrade PC"
#cd /home/nutanix/install ; ./bin/cluster -i . -p upgrade

my_log "PC Configuration complete on `$date`"
