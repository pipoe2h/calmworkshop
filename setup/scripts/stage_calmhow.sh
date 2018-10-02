#!/bin/bash
# -x
# Dependencies: acli, ncli, dig, jq, sshpass, curl, md5sum, pgrep, wc, tr, pkill
# Please configure according to your needs

function _TestDNS {
  CheckArgsExist 'LDAP_HOST MY_DOMAIN_FQDN'
  local   _DNS=$(dig +retry=0 +time=2 +short @${LDAP_HOST} dc1.${MY_DOMAIN_FQDN})
  local _ERROR=44
  local  _TEST=$?

  if [[ ${_DNS} != "${LDAP_HOST}" ]]; then
    log "Error ${_ERROR}: result was ${_TEST}: ${_DNS}"
    return ${_ERROR}
  fi
}

function acli {
  local CMD=$@
	/usr/local/nutanix/bin/acli ${CMD}
  # DEBUG=1 && if [[ ${DEBUG} ]]; then log "$@"; fi
}

function PE_Init
{
  CheckArgsExist 'HPOC_PREFIX octet MY_EMAIL \
    SMTP_SERVER_ADDRESS SMTP_SERVER_FROM SMTP_SERVER_PORT \
    MY_CONTAINER_NAME MY_SP_NAME MY_IMG_CONTAINER_NAME \
    SLEEP ATTEMPTS'

  local _DATA_SERVICE_IP=${HPOC_PREFIX}.$((${octet[3]} + 1))

  if [[ `ncli cluster get-params | grep 'External Data' | \
         awk -F: '{print $2}' | tr -d '[:space:]'` == "${_DATA_SERVICE_IP}" ]]; then
    log "IDEMPOTENCY: Data Services IP set, skip."
  else
    log "Configure SMTP: https://sewiki.nutanix.com/index.php/Hosted_POC_FAQ#I.27d_like_to_test_email_alert_functionality.2C_what_SMTP_server_can_I_use_on_Hosted_POC_clusters.3F"
    ncli cluster set-smtp-server port=${SMTP_SERVER_PORT} \
      from-email-address=${SMTP_SERVER_FROM} address=${SMTP_SERVER_ADDRESS}
    ${HOME}/serviceability/bin/email-alerts --to_addresses="${MY_EMAIL}" \
      --subject="[PE_Init:Config SMTP:alert test] `ncli cluster get-params`" \
      && ${HOME}/serviceability/bin/send-email

    log "Configure NTP"
    ncli cluster add-to-ntp-servers \
      servers=0.us.pool.ntp.org,1.us.pool.ntp.org,2.us.pool.ntp.org,3.us.pool.ntp.org

    log "Rename default container to ${MY_CONTAINER_NAME}"
    default_container=$(ncli container ls | grep -P '^(?!.*VStore Name).*Name' \
      | cut -d ':' -f 2 | sed s/' '//g | grep '^default-container-')
    ncli container edit name="${default_container}" new-name="${MY_CONTAINER_NAME}"

    log "Rename default storage pool to ${MY_SP_NAME}"
    default_sp=$(ncli storagepool ls | grep 'Name' | cut -d ':' -f 2 | sed s/' '//g)
    ncli sp edit name="${default_sp}" new-name="${MY_SP_NAME}"

    log "Check if there is a container named ${MY_IMG_CONTAINER_NAME}, if not create one"
    (ncli container ls | grep -P '^(?!.*VStore Name).*Name' \
      | cut -d ':' -f 2 | sed s/' '//g | grep "^${MY_IMG_CONTAINER_NAME}" 2>&1 > /dev/null) \
      && log "Container ${MY_IMG_CONTAINER_NAME} exists" \
      || ncli container create name="${MY_IMG_CONTAINER_NAME}" sp-name="${MY_SP_NAME}"

    # Set external IP address:
    #ncli cluster edit-params external-ip-address=${MY_PE_HOST}

    log "Set Data Services IP address to ${_DATA_SERVICE_IP}"
    ncli cluster edit-params external-data-services-ip-address=${_DATA_SERVICE_IP}
  fi
}

function Network_Configure
{
  # From this point, we assume according to SEWiki:
  # IP Range: ${HPOC_PREFIX}.0/25
  # Gateway: ${HPOC_PREFIX}.1
  # DNS: 10.21.253.10,10.21.253.11
  # DHCP Pool: ${HPOC_PREFIX}.50 - ${HPOC_PREFIX}.120

  CheckArgsExist 'MY_PRIMARY_NET_NAME MY_PRIMARY_NET_VLAN MY_SECONDARY_NET_NAME MY_SECONDARY_NET_VLAN MY_DOMAIN_NAME HPOC_PREFIX LDAP_HOST'

  if [[ ! -z `acli "net.list" | grep ${MY_SECONDARY_NET_NAME}` ]]; then
    log "IDEMPOTENCY: ${MY_SECONDARY_NET_NAME} network set, skip"
  else
    log "Remove Rx-Automation-Network if it exists..."
    acli "-y net.delete Rx-Automation-Network"

    log "Create primary network: Name: ${MY_PRIMARY_NET_NAME}"
    # log "VLAN: ${MY_PRIMARY_NET_VLAN}"
    # log "Subnet: ${HPOC_PREFIX}.1/25"
    # log "Domain: ${MY_DOMAIN_NAME}"
    # log "Pool: ${HPOC_PREFIX}.50 to ${HPOC_PREFIX}.125"
    acli "net.create ${MY_PRIMARY_NET_NAME} vlan=${MY_PRIMARY_NET_VLAN} ip_config=${HPOC_PREFIX}.1/25"
    acli "net.update_dhcp_dns ${MY_PRIMARY_NET_NAME} servers=${LDAP_HOST},10.21.253.10 domains=${MY_DOMAIN_NAME}"
    acli "net.add_dhcp_pool ${MY_PRIMARY_NET_NAME} start=${HPOC_PREFIX}.50 end=${HPOC_PREFIX}.125"

    if [[ ${MY_SECONDARY_NET_NAME} ]]; then
      log "Create secondary network: Name: ${MY_SECONDARY_NET_NAME}"
      # log "VLAN: ${MY_SECONDARY_NET_VLAN}"
      # log "Subnet: ${HPOC_PREFIX}.129/25"
      # log "Domain: ${MY_DOMAIN_NAME}"
      # log "Pool: ${HPOC_PREFIX}.132 to ${HPOC_PREFIX}.253"
      acli "net.create ${MY_SECONDARY_NET_NAME} vlan=${MY_SECONDARY_NET_VLAN} ip_config=${HPOC_PREFIX}.129/25"
      acli "net.update_dhcp_dns ${MY_SECONDARY_NET_NAME} servers=${LDAP_HOST},10.21.253.10 domains=${MY_DOMAIN_NAME}"
      acli "net.add_dhcp_pool ${MY_SECONDARY_NET_NAME} start=${HPOC_PREFIX}.132 end=${HPOC_PREFIX}.253"
    fi
  fi
}

function AuthenticationServer()
{
  CheckArgsExist 'LDAP_SERVER MY_DOMAIN_FQDN SLEEP MY_IMG_CONTAINER_NAME'

  if [[ -z ${LDAP_SERVER} ]]; then
    log "Error: please provide a choice for authentication server."
    exit 13
  fi

  case "${LDAP_SERVER}" in
    'ActiveDirectory')
      log "Manual setup = http://www.nutanixworkshops.com/en/latest/setup/active_directory/active_directory_setup.html"
      ;;
    'AutoDC')
      local _RESULT
      _TestDNS; _RESULT=$?

      if (( ${_RESULT} == 0 )); then
        log "${LDAP_SERVER}.IDEMPOTENCY: dc1.${MY_DOMAIN_FQDN} set, skip. ${_RESULT}"
      else
        log "${LDAP_SERVER}.IDEMPOTENCY failed, no DNS record dc1.${MY_DOMAIN_FQDN}"
        log "Import ${LDAP_SERVER} image..."

        local _ERROR=12
        local  _LOOP=0
        local _SLEEP=${SLEEP}
        local  _TEST

# task.list operation_type_list=kVmCreate
# Task UUID                             Parent Task UUID  Component  Sequence-id  Type       Status
# b21efb77-5447-45f9-9d6e-fc3ef6b22e36                    Acropolis  54           kVmCreate  kSucceeded
#
# acli -o json-pretty task.get b21efb77-5447-45f9-9d6e-fc3ef6b22e36
# {
#   "data": {
#     "canceled": false,
#     "cluster_uuid": "00056e27-2f51-7a31-1a72-0cc47ac3b4a0",
#     "complete_time_usecs": "2018-06-09T00:52:11.527367",
#     "component": "Acropolis",
#     "create_time_usecs": "2018-06-09T00:52:11.380946",
#     "deleted": false,
#     "disable_auto_progress_update": true,
#     "entity_list": [
#       {
#         "entity_id": "1dbcb887-c368-4142-97be-ff53417355ad",
#         "entity_type": "kVM"
#       }
#     ],
#     "internal_opaque": "ChIKEB28uIfDaEFCl77/U0FzVa0=",
#     "internal_task": false,
#     "last_updated_time_usecs": "2018-06-09T00:52:11.527367",
#     "local_root_task_uuid": "b21efb77-5447-45f9-9d6e-fc3ef6b22e36",
#     "logical_timestamp": 1,
#     "message": "",
#     "operation_type": "kVmCreate",
#     "percentage_complete": 100,
#     "request": {
#       "arg": {
#         "spec": {
#           "memory_mb": 2048,
#           "name": "STAGING-FAILED-AutoDC",
#           "num_vcpus": 1
#         }
#       },
#       "method_name": "VmCreate"
#     },
#     "requested_state_transition": 20,
#     "response": {
#       "error_code": 0,
#       "ret": {
#         "embedded": "ChAdvLiHw2hBQpe+/1NBc1Wt"
#       }
#     },
#     "sequence_id": 54,
#     "start_time_usecs": "2018-06-09T00:52:11.433001",
#     "status": "kSucceeded",
#     "uuid": "b21efb77-5447-45f9-9d6e-fc3ef6b22e36",
#     "weight": 1000
#   },
#   "error": null,
#   "status": 0
# }

        # while true ; do
        #   (( _LOOP++ ))
        if (( `source /etc/profile.d/nutanix_env.sh && acli image.list | grep ${LDAP_SERVER} | wc --lines` == 0 )); then
          acli image.create ${LDAP_SERVER} \
            container=${MY_IMG_CONTAINER_NAME} \
            image_type=kDiskImage \
            source_url=https://s3.amazonaws.com/get-ahv-images/AutoDC-04282018.qcow2 \
            wait=true
        fi

          # if [[ ${_TEST} =~ 'complete' ]]; then
          #   break
          # elif (( ${_LOOP} > ${ATTEMPTS} )); then
          #   acli "vm.create STAGING-FAILED-${LDAP_SERVER}"
          #   log "${LDAP_SERVER} failed to upload after ${_LOOP} attempts. This cluster may require manual remediation."
          #   exit 13
          # else
          #   log "_TEST ${_LOOP}=${_TEST}: ${LDAP_SERVER} failed. Sleep ${_SLEEP} seconds..."
          #   sleep ${_SLEEP}
          # fi
        # done

        log "Create ${LDAP_SERVER} VM based on ${LDAP_SERVER} image"
        acli "vm.create ${LDAP_SERVER} num_vcpus=2 num_cores_per_vcpu=1 memory=2G"
        # vmstat --wide --unit M --active # suggests 2G sufficient, was 4G
        acli "vm.disk_create ${LDAP_SERVER} cdrom=true empty=true"
        acli "vm.disk_create ${LDAP_SERVER} clone_from_image=${LDAP_SERVER}"
        acli "vm.nic_create ${LDAP_SERVER} network=${MY_PRIMARY_NET_NAME} ip=${LDAP_HOST}"

        log "Power on ${LDAP_SERVER} VM..."
        acli "vm.on ${LDAP_SERVER}"

        local _ATTEMPTS=20
         _LOOP=0
        _SLEEP=7

        while true ; do
          (( _LOOP++ ))
          _TEST=$(remote_exec 'SSH' 'LDAP_SERVER' 'systemctl show samba-ad-dc --property=SubState')

          if [[ "${_TEST}" == "SubState=running" ]]; then
            log "${LDAP_SERVER} is ready."
            sleep ${_SLEEP}
            break
          elif (( ${_LOOP} > ${_ATTEMPTS} )); then
            log "Error ${_ERROR}: ${LDAP_SERVER} VM running: giving up after ${_LOOP} tries."
            acli "-y vm.delete ${LDAP_SERVER}"
            log "Remediate by deleting the ${LDAP_SERVER} VM from PE (just attempted by this script) and then running $_"
            exit ${_ERROR}
          else
            log "_TEST ${_LOOP}/${_ATTEMPTS}=|${_TEST}|: sleep ${_SLEEP} seconds..."
            sleep ${_SLEEP}
          fi
        done

        log "Create Reverse Lookup Zone on ${LDAP_SERVER} VM..."
        _ATTEMPTS=3
            _LOOP=0

        while true ; do
          (( _LOOP++ ))
          # TODO:130 Samba service reload better? vs. force-reload and restart
          remote_exec 'SSH' 'LDAP_SERVER' \
            "samba-tool dns zonecreate dc1 ${octet[2]}.${octet[1]}.${octet[0]}.in-addr.arpa && service samba-ad-dc restart" \
            'OPTIONAL'
          sleep ${_SLEEP}

          _TestDNS; _RESULT=$?

          if (( ${_RESULT} == 0 )); then
            log "Success: DNS record dc1.${MY_DOMAIN_FQDN} set."
            break
          elif (( ${_LOOP} > ${_ATTEMPTS} )); then
            log "Error ${_ERROR}: ${LDAP_SERVER}: giving up after ${_LOOP} tries; deleting VM..."
            acli "-y vm.delete ${LDAP_SERVER}"
            exit ${_ERROR}
          else
            log "_TestDNS ${_LOOP}/${_ATTEMPTS}=|${_RESULT}|: sleep ${_SLEEP} seconds..."
            sleep ${_SLEEP}
          fi
        done

      fi
      ;;
    'OpenLDAP')
      log "To be documented, see https://drt-it-github-prod-1.eng.nutanix.com/mark-lavi/openldap"
      ;;
  esac
}

function PE_Auth
{
  CheckArgsExist 'MY_DOMAIN_NAME MY_DOMAIN_FQDN MY_DOMAIN_URL MY_DOMAIN_USER MY_DOMAIN_PASS MY_DOMAIN_ADMIN_GROUP'

  if [[ -z `ncli authconfig list-directory name=${MY_DOMAIN_NAME} | grep Error` ]]; then
    log "IDEMPOTENCY: ${MY_DOMAIN_NAME} directory set, skip."
  else
    log "Configure PE external authentication"
    ncli authconfig add-directory \
      directory-type=ACTIVE_DIRECTORY \
      connection-type=LDAP directory-url="${MY_DOMAIN_URL}" \
      domain="${MY_DOMAIN_FQDN}" \
      name="${MY_DOMAIN_NAME}" \
      service-account-username="${MY_DOMAIN_USER}" \
      service-account-password="${MY_DOMAIN_PASS}"

    log "Configure PE role map"
    ncli authconfig add-role-mapping \
      role=ROLE_CLUSTER_ADMIN \
      entity-type=group name="${MY_DOMAIN_NAME}" \
      entity-values="${MY_DOMAIN_ADMIN_GROUP}"
  fi
}

function PE_License
{
  CheckArgsExist 'CURL_POST_OPTS MY_PE_PASSWORD'

  log "IDEMPOTENCY: Checking PC API responds, curl failures are acceptable..."
  Check_Prism_API_Up 'PC' 2 0

  if (( $? == 0 )) ; then
    log "IDEMPOTENCY: PC API responds, skip"
  else
    log "Validate EULA on PE"
    curl ${CURL_POST_OPTS} --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X POST --data '{
      "username": "SE with stage_calmhow.sh",
      "companyName": "Nutanix",
      "jobTitle": "SE"
    }' https://localhost:9440/PrismGateway/services/rest/v1/eulas/accept

    log "Disable Pulse in PE"
    curl ${CURL_POST_OPTS} --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X PUT --data '{
      "defaultNutanixEmail": null,
      "emailContactList": null,
      "enable": false,
      "enableDefaultNutanixEmail": false,
      "isPulsePromptNeeded": false,
      "nosVersion": null,
      "remindLater": null,
      "verbosityType": null
    }' https://localhost:9440/PrismGateway/services/rest/v1/pulse

    #echo; log "Create PE Banner Login" # TODO: for PC, login banner
    # https://portal.nutanix.com/#/page/docs/details?targetId=Prism-Central-Guide-Prism-v56:mul-welcome-banner-configure-pc-t.html
    # curl ${CURL_POST_OPTS} --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X POST --data \
    #  '{type: "welcome_banner", key: "welcome_banner_status", value: true}' \
    #  https://localhost:9440/PrismGateway/services/rest/v1/application/system_data
    #curl ${CURL_POST_OPTS} --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X POST --data
    #  '{type: "welcome_banner", key: "welcome_banner_content", value: "HPoC '${octet[2]}' password = '${MY_PE_PASSWORD}'"}' \
    #  https://localhost:9440/PrismGateway/services/rest/v1/application/system_data
  fi
}

function PC_Download
{
  CheckArgsExist 'MY_PC_VERSION'

  MY_PC_META_URL='http://download.nutanix.com/pc/one-click-pc-deployment/'${MY_PC_VERSION}

  case ${MY_PC_VERSION} in
    5.6.1 )
      MY_PC_META_URL+=\ #'http://10.21.250.221/images/ahv/techsummit/euphrates-5.6-stable-prism_central_metadata.json'
     '/v1/euphrates-5.6.1-stable-prism_central_metadata.json'
      ;;
    5.7.0.1 | 5.7.1 )
      MY_PC_META_URL='http://10.21.249.53/pc-5.7.1-stable-prism_central_metadata.json'
      MY_PC_META_URL+="/v1/pc-${MY_PC_VERSION}-stable-prism_central_metadata.json"
      ;;
    5.8.0.1 )
      MY_PC_META_URL+='/v2/euphrates-5.8.0.1-stable-prism_central_metadata.json'
      ;;
    5.8.1 | 5.8.2 | 5.9 | 5.10 | 5.11 )
      MY_PC_META_URL+="/v1/pc_deploy-${MY_PC_VERSION}.json"
      ;;
    * )
      _ERROR=22
      log "Error ${_ERROR}: unsupported MY_PC_VERSION=${MY_PC_VERSION}!"
      log 'Browse to https://portal.nutanix.com/#/page/releases/prismDetails'
      log " - Find ${MY_PC_VERSION} in the Additional Releases section on the lower left side"
      log ' - Provide the metadata URL for the "PC 1-click deploy from PE" option.'
      exit ${_ERROR}
      ;;
  esac

  if [[ ! -e ${MY_PC_META_URL##*/} ]]; then
    log "Retrieving Prism Central metadata ${MY_PC_META_URL} ..."
    Download "${MY_PC_META_URL}"
  else
    log "Warning: using cached ${MY_PC_META_URL##*/}"
  fi

  MY_PC_SRC_URL=$(cat ${MY_PC_META_URL##*/} | jq -r .download_url_cdn)

  if (( `pgrep curl | wc --lines | tr -d '[:space:]'` > 0 )); then
    pkill curl
  fi
  log "Retrieving Prism Central bits..."
  Download "${MY_PC_SRC_URL}"
}

function PC_Init
{
  log "IDEMPOTENCY: Checking PC API responds, curl failures are acceptable..."
  Check_Prism_API_Up 'PC' 2 0

  if (( $? == 0 )) ; then
    log "IDEMPOTENCY: PC API responds, skip."
  else
    log "Get NET_UUID,MY_CONTAINER_UUID from cluster: PC_Init dependency."
    MY_NET_UUID=$(acli "net.get ${MY_PRIMARY_NET_NAME}" | grep "uuid" | cut -f 2 -d ':' | xargs)
    log "${MY_PRIMARY_NET_NAME} UUID is ${MY_NET_UUID}"
    MY_CONTAINER_UUID=$(ncli container ls name=${MY_CONTAINER_NAME} | grep Uuid | grep -v Pool | cut -f 2 -d ':' | xargs)
    log "${MY_CONTAINER_NAME} UUID is ${MY_CONTAINER_UUID}"

    PC_Download

    local _CHECKSUM=$(md5sum ${MY_PC_SRC_URL##*/} | awk '{print $1}')
    if [[ `cat ${MY_PC_META_URL##*/} | jq -r .hex_md5` != ${_CHECKSUM} ]]; then
      log "Error: md5sum ${_CHECKSUM} doesn't match on: ${MY_PC_SRC_URL##*/} removing and exit!"
      rm -f ${MY_PC_SRC_URL##*/}
      exit 2
    else
      log "Prism Central downloaded and passed MD5 checksum!"
    fi

    log "Prism Central upload..."
    ncli software upload file-path=`pwd`/${MY_PC_SRC_URL##*/} \
      meta-file-path=`pwd`/${MY_PC_META_URL##*/} \
      software-type=PRISM_CENTRAL_DEPLOY

    MY_PC_RELEASE=$(cat ${MY_PC_META_URL##*/} | jq -r .version_id)

    log "Delete PC sources to free CVM space..."
    rm -f ${MY_PC_SRC_URL##*/} ${MY_PC_META_URL##*/}

    log "Deploy Prism Central (typically takes 17+ minutes)..."
    # TODO:150 Parameterize DNS Servers & add secondary
    # TODO:120 make scale-out & dynamic, was: 4vCPU/16GB = 17179869184, 8vCPU/40GB = 42949672960
    local _LDAP_SERVER=
    HTTP_BODY=$(cat <<EOF
{
  "resources": {
    "should_auto_register":true,
    "version":"${MY_PC_VERSION}",
    "pc_vm_list":[{
      "data_disk_size_bytes":536870912000,
      "nic_list":[{
        "network_configuration":{
          "subnet_mask":"255.255.255.128",
          "network_uuid":"${MY_NET_UUID}",
          "default_gateway":"${HPOC_PREFIX}.1"
        },
        "ip_list":["${MY_PC_HOST}"]
      }],
      "dns_server_ip_list":["${LDAP_HOST}"],
      "container_uuid":"${MY_CONTAINER_UUID}",
      "num_sockets":8,
      "memory_size_bytes":42949672960,
      "vm_name":"Prism Central ${MY_PC_RELEASE}"
    }]
  }
}
EOF
    )
    local _TEST
    _TEST=$(curl ${CURL_POST_OPTS} --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} \
      -X POST --data "${HTTP_BODY}" \
      https://localhost:9440/api/nutanix/v3/prism_central)
    #log "_TEST=|${_TEST}|"
  fi
}

function PC_Configure {
  local _CONTAINER
  local _PC_FILES='common.lib.sh global.vars.sh stage_calmhow_pc.sh'
  log "Send configuration scripts to PC and remove: ${_PC_FILES}"
  remote_exec 'scp' 'PC' "${_PC_FILES}" && rm -f ${_PC_FILES}

  _PC_FILES='jq-linux64 sshpass-1.06-2.el7.x86_64.rpm id_rsa.pub'
  log "OPTIONAL: Send binary dependencies to PC: ${_PC_FILES}"
  remote_exec 'scp' 'PC' "${_PC_FILES}" 'OPTIONAL'

  for _CONTAINER in epsilon nucalm ; do
    if [[ -e ${_CONTAINER}.tar ]]; then
      log "Uploading Calm container updates in background..."
      remote_exec 'SCP' 'PC' ${_CONTAINER}.tar 'OPTIONAL' &
    fi
  done

  # Execute that file asynchroneously remotely (script keeps running on CVM in the background)
  log "Launch PC configuration script"
  remote_exec 'ssh' 'PC' \
    "MY_EMAIL=${MY_EMAIL} MY_PC_HOST=${MY_PC_HOST} MY_PE_PASSWORD=${MY_PE_PASSWORD} MY_PC_VERSION=${MY_PC_VERSION} \
    nohup bash /home/nutanix/stage_calmhow_pc.sh >> stage_calmhow_pc.log 2>&1 &"
  log "PC Configuration complete: try Validate Staged Clusters now."
}

#__main()__________

# Source Nutanix environment (PATH + aliases), then Workshop common routines + global variables
. /etc/profile.d/nutanix_env.sh
. common.lib.sh
. global.vars.sh

log `basename "$0"`": PID=$$"

CheckArgsExist 'MY_EMAIL MY_PE_HOST MY_PE_PASSWORD MY_PC_VERSION'

#Dependencies 'install' 'jq' && PC_Download & #attempt at parallelization

log "Adding key to PE/CVMs..." && SSH_PubKey || true & # non-blocking, parallel suitable

# Some parallelization possible to critical path; not much: would require pre-requestite checks to work!
Dependencies 'install' 'sshpass' && Dependencies 'install' 'jq' \
&& PE_License \
&& PE_Init \
&& Network_Configure \
&& AuthenticationServer \
&& PE_Auth \
&& PC_Init \
&& Check_Prism_API_Up 'PC'

if (( $? == 0 )) ; then
  PC_Configure && Dependencies 'remove' 'sshpass' && Dependencies 'remove' 'jq';
  log "PC Configuration complete: Waiting for PC deployment to complete, API is up!"
  log "PE = https://${MY_PE_HOST}:9440"
  log "PC = https://${MY_PC_HOST}:9440"
  log "${0} ran for ${SECONDS} seconds."
  log "$0: done!_____________________"

  echo
else
  log "Error 18: in main functional chain, exit!"
  exit 18
fi
