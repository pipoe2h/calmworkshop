#!/bin/bash
# -x
# Dependencies: curl, ncli, nuclei, jq #sshpass (removed, needed for remote)

function PC_LDAP
{ # TODO:170 configure case for each authentication server type?
  local _GROUP
  local _HTTP_BODY
  local _TEST

  log "Add Directory ${LDAP_SERVER}"
  _HTTP_BODY=$(cat <<EOF
  {
    "name":"${LDAP_SERVER}",
    "domain":"${MY_DOMAIN_FQDN}",
    "directoryUrl":"ldaps://${LDAP_HOST}/",
    "directoryType":"ACTIVE_DIRECTORY",
    "connectionType":"LDAP",
    "serviceAccountUsername":"${MY_DOMAIN_USER}",
    "serviceAccountPassword":"${MY_DOMAIN_PASS}"
  }
EOF
  )

  _TEST=$(curl ${CURL_POST_OPTS} \
    --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X POST --data "${_HTTP_BODY}" \
    https://localhost:9440/PrismGateway/services/rest/v1/authconfig/directories)
  log "_TEST=|${_TEST}|"

  log "Add Role Mappings to Groups for PC logins (not projects, which are separate)..." #TODO:40 hardcoded role mappings
  for _GROUP in 'SSP Admins' 'SSP Power Users' 'SSP Developers' 'SSP Basic Users'; do
    _HTTP_BODY=$(cat <<EOF
    {
      "directoryName":"${LDAP_SERVER}",
      "role":"ROLE_CLUSTER_ADMIN",
      "entityType":"GROUP",
      "entityValues":["${_GROUP}"]
    }
EOF
    )
    _TEST=$(curl ${CURL_POST_OPTS} \
      --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X POST --data "${_HTTP_BODY}" \
      https://localhost:9440/PrismGateway/services/rest/v1/authconfig/directories/${LDAP_SERVER}/role_mappings)
    log "Cluster Admin=${_GROUP}, _TEST=|${_TEST}|"
  done
}

function SSP_Auth {
  CheckArgsExist 'LDAP_SERVER LDAP_HOST MY_DOMAIN_FQDN MY_DOMAIN_USER MY_DOMAIN_PASS'

  local _HTTP_BODY
  local _LDAP_UUID

  log "Find ${LDAP_SERVER} uuid"
  _LDAP_UUID=$(PATH=${PATH}:${HOME}; curl ${CURL_POST_OPTS} \
    --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} --data "{ "kind": "directory_service" }" \
    https://localhost:9440/api/nutanix/v3/directory_services/list \
    | jq -r .entities[0].metadata.uuid)
  log "_LDAP_UUID=|${_LDAP_UUID}|"

  # TODO:20 get directory service name _LDAP_NAME
  _LDAP_NAME=${LDAP_SERVER}
  # TODO:80 bats? test ldap connection

  log "Connect SSP Authentication (spec-ssp-authrole.json)..."
  _HTTP_BODY=$(cat <<EOF
  {
    "spec": {
      "name": "${LDAP_SERVER}",
      "resources": {
        "admin_group_reference_list": [
          {
            "name": "cn=ssp developers,cn=users,dc=ntnxlab,dc=local",
            "uuid": "3933a846-fe73-4387-bb39-7d66f222c844",
            "kind": "user_group"
          }
        ],
        "service_account": {
          "username": "${MY_DOMAIN_USER}",
          "password": "${MY_DOMAIN_PASS}"
        },
        "url": "ldaps://${LDAP_HOST}/",
        "directory_type": "ACTIVE_DIRECTORY",
        "admin_user_reference_list": [],
        "domain_name": "${MY_DOMAIN_FQDN}"
      }
    },
    "metadata": {
      "kind": "directory_service",
      "spec_version": 0,
      "uuid": "${_LDAP_UUID}",
      "categories": {}
    },
    "api_version": "3.1.0"
  }
EOF
  )
  SSP_CONNECT=$(curl ${CURL_POST_OPTS} \
    --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X PUT --data "${_HTTP_BODY}" \
    https://localhost:9440/api/nutanix/v3/directory_services/${_LDAP_UUID})
  log "SSP_CONNECT=|${SSP_CONNECT}|"

  # TODO:60 SSP Admin assignment, cluster, networks (default project?) = spec-project-config.json
  # PUT https://10.21.47.39:9440/api/nutanix/v3/directory_services/9d8c2c33-9d95-438c-a7f4-2187120ae99e = spec-ssp-direcory_service.json
  # TODO:0 make directory_type variable?
  log "Enable SSP Admin Authentication (spec-ssp-direcory_service.json)..."
  _HTTP_BODY=$(cat <<EOF
  {
    "spec": {
      "name": "${_LDAP_NAME}",
      "resources": {
        "service_account": {
          "username": "${MY_DOMAIN_USER}@${MY_DOMAIN_FQDN}",
          "password": "${MY_DOMAIN_PASS}"
        },
        "url": "ldaps://${LDAP_HOST}/",
        "directory_type": "ACTIVE_DIRECTORY",
        "domain_name": "${MY_DOMAIN_FQDN}"
      }
    },
    "metadata": {
      "kind": "directory_service",
      "spec_version": 0,
      "uuid": "${_LDAP_UUID}",
      "categories": {}
    },
    "api_version": "3.1.0"
  }
EOF
  )
  SSP_CONNECT=$(curl ${CURL_POST_OPTS} \
    --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X PUT --data "${_HTTP_BODY}" \
    https://localhost:9440/api/nutanix/v3/directory_services/${_LDAP_UUID})
  log "SSP_CONNECT=|${SSP_CONNECT}|"
  # POST https://10.21.47.39:9440/api/nutanix/v3/groups = spec-ssp-groups.json
  # TODO:10 can we skip previous step?
  log "Enable SSP Admin Authentication (spec-ssp-groupauth_2.json)..."
  _HTTP_BODY=$(cat <<EOF
  {
    "spec": {
      "name": "${_LDAP_NAME}",
      "resources": {
        "service_account": {
          "username": "${MY_DOMAIN_USER}@${MY_DOMAIN_FQDN}",
          "password": "${MY_DOMAIN_PASS}"
        },
        "url": "ldaps://${LDAP_HOST}/",
        "directory_type": "ACTIVE_DIRECTORY",
        "domain_name": "${MY_DOMAIN_FQDN}"
        "admin_user_reference_list": [],
        "admin_group_reference_list": [
          {
            "kind": "user_group",
            "name": "cn=ssp admins,cn=users,dc=ntnxlab,dc=local",
            "uuid": "45d495e1-b797-4a26-a45b-0ef589b42186"
          }
        ]
      }
    },
    "api_version": "3.1",
    "metadata": {
      "last_update_time": "2018-09-14T13:02:55Z",
      "kind": "directory_service",
      "uuid": "${_LDAP_UUID}",
      "creation_time": "2018-09-14T13:02:55Z",
      "spec_version": 2,
      "owner_reference": {
        "kind": "user",
        "name": "admin",
        "uuid": "00000000-0000-0000-0000-000000000000"
      },
      "categories": {}
    }
  }
  EOF
    )
    SSP_CONNECT=$(curl ${CURL_POST_OPTS} \
      --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X PUT --data "${_HTTP_BODY}" \
      https://localhost:9440/api/nutanix/v3/directory_services/${_LDAP_UUID})
    log "SSP_CONNECT=|${SSP_CONNECT}|"

}

function Enable_Calm
{
  local _HTTP_BODY
  local _TEST

  log "Enable Nutanix Calm..."
  _HTTP_BODY=$(cat <<EOF
  {
    "state": "ENABLE",
    "enable_nutanix_apps": true
  }
EOF
  )
  _HTTP_BODY='{"enable_nutanix_apps":true,"state":"ENABLE"}'
  _TEST=$(curl ${CURL_POST_OPTS} \
    --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X POST --data "${_HTTP_BODY}" \
    https://localhost:9440/api/nutanix/v3/services/nucalm)
  log "_TEST=|${_TEST}|"
}

function PC_UI
{ # http://vcdx56.com/2017/08/change-nutanix-prism-ui-login-screen/ PC UI customization

  local _JSON=$(cat <<EOF
{"type":"custom_login_screen","key":"color_in","value":"#ADD100"} \
{"type":"custom_login_screen","key":"color_out","value":"#11A3D7"} \
{"type":"custom_login_screen","key":"product_title","value":"PC-${MY_PC_VERSION}"} \
{"type":"custom_login_screen","key":"title","value":"Welcome_to_NutanixWorkshops.com,@${MY_DOMAIN_FQDN}"} \
{"type":"welcome_banner","key":"disable_video","value":true} \
{"type":"disable_2048","key":"disable_video","value":true} \
{"type":"UI_CONFIG","key":"autoLogoutGlobal","value":7200000} \
{"type":"UI_CONFIG","key":"autoLogoutOverride","value":0} \
{"type":"UI_CONFIG","key":"welcome_banner","value":"http://NutanixWorkshops.com"}
EOF
  )
  local _TEST

  for _HTTP_BODY in ${_JSON}; do
    _TEST=$(curl ${CURL_HTTP_OPTS} \
      --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X POST --data "${_HTTP_BODY}" \
      https://localhost:9440/PrismGateway/services/rest/v1/application/system_data)
    log "_TEST=|${_TEST}|${_HTTP_BODY}"
  done

  _HTTP_BODY='{"type":"UI_CONFIG","key":"autoLogoutTime","value": 3600000}'
       _TEST=$(curl ${CURL_HTTP_OPTS} \
    --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X POST --data "${_HTTP_BODY}" \
    https://localhost:9440/PrismGateway/services/rest/v1/application/user_data)
  log "autoLogoutTime _TEST=|${_TEST}|"
}

function PC_Init
{ # depends on ncli
  # TODO:70 PC_Init: NCLI, type 'cluster get-smtp-server' config for idempotency?

  local _TEST
  local OLD_PW='nutanix/4u'

  log "Reset PC password to PE password, must be done by nci@PC, not API or on PE"
  ncli user reset-password user-name=${PRISM_ADMIN} password=${MY_PE_PASSWORD}
  if (( $? != 0 )); then
   log "Warning: password not reset: $?."# exit 10
   # TOFIX: nutanix@PC Linux account password change as well?
  fi
#   _HTTP_BODY=$(cat <<EOF
# {"oldPassword": "${OLD_PW}","newPassword": "${MY_PE_PASSWORD}"}
# EOF
#   )
#   PC_TEST=$(curl ${CURL_HTTP_OPTS} --user "${PRISM_ADMIN}:${OLD_PW}" -X POST --data "${_HTTP_BODY}" \
#     https://localhost:9440/PrismGateway/services/rest/v1/utils/change_default_system_password)
#   log "cURL reset password PC_TEST=${PC_TEST}"

  log "Configure NTP@PC"
  ncli cluster add-to-ntp-servers \
    servers=0.us.pool.ntp.org,1.us.pool.ntp.org,2.us.pool.ntp.org,3.us.pool.ntp.org

  log "Validate EULA@PC"
  _TEST=$(curl ${CURL_HTTP_OPTS} --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X POST -d '{
      "username": "SE",
      "companyName": "NTNX",
      "jobTitle": "SE"
  }' https://localhost:9440/PrismGateway/services/rest/v1/eulas/accept)
  log "EULA _TEST=|${_TEST}|"

  log "Disable Pulse@PC"
  _TEST=$(curl ${CURL_HTTP_OPTS} --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X PUT -d '{
      "emailContactList":null,
      "enable":false,
      "verbosityType":null,
      "enableDefaultNutanixEmail":false,
      "defaultNutanixEmail":null,
      "nosVersion":null,
      "isPulsePromptNeeded":false,
      "remindLater":null
  }' https://localhost:9440/PrismGateway/services/rest/v1/pulse)
  log "PULSE _TEST=|${_TEST}|"
}

function Images
{ # depends on nuclei
  # TOFIX: https://jira.nutanix.com/browse/FEAT-7112
  # https://jira.nutanix.com/browse/ENG-115366
  # once PC image service takes control, rejects PE image uploads. Move to PC, not critical path.
  # KB 4892 = https://portal.nutanix.com/#/page/kbs/details?targetId=kA00e000000XePyCAK
  # v3 API = http://developer.nutanix.com/reference/prism_central/v3/#images two steps:
  # 1. POST /images to create image metadata and get UUID
    #   {
    #   "spec": {
    #     "name": "string",
    #     "resources": {
    #       "image_type": "string",
    #       "checksum": {
    #         "checksum_algorithm": "string",
    #         "checksum_value": "string"
    #       },
    #       "source_uri": "string",
    #       "version": {
    #         "product_version": "string",
    #         "product_name": "string"
    #       },
    #       "architecture": "string"
    #     },
    #     "description": "string"
    #   },
    #   "api_version": "3.1.0",
    #   "metadata": {
    #     "last_update_time": "2018-05-20T16:45:50.090Z",
    #     "kind": "image",
    #     "uuid": "string",
    #     "project_reference": {
    #       "kind": "project",
    #       "name": "string",
    #       "uuid": "string"
    #     },
    #     "spec_version": 0,
    #     "creation_time": "2018-05-20T16:45:50.090Z",
    #     "spec_hash": "string",
    #     "owner_reference": {
    #       "kind": "user",
    #       "name": "string",
    #       "uuid": "string"
    #     },
    #     "categories": {},
    #     "name": "string"
    #   }
    # }
  # 2.  PUT images/uuid/file: upload uuid, body, checksum and checksum type: sha1, sha256
  # or nuclei, only on PCVM or in container

  for IMG in CentOS7-06252018.qcow2 Windows2012R2-04282018.qcow2 Windows10-1709-04282018.qcow2 Nutanix-VirtIO-1.1.3.iso ; do
    log "${IMG} image.create..."
    nuclei image.create name=${IMG} \
       description="${0} via stage_calmhow_pc for ${IMG}" \
       #source_uri=http://10.21.250.221/images/ahv/techsummit/${IMG}
       source_uri=https://s3.amazonaws.com/get-ahv-images/${IMG}
     log "NOTE: image.uuid = RUNNING, but takes a while to show up in:"
     log "TODO: nuclei image.list, state = COMPLETE; image.list Name UUID State"
    if (( $? != 0 )); then
      log "Warning: Image submission: $?."
      #exit 10
    fi
  done
}

function PC_SMTP {
  log "Configure SMTP@PC"
  local _SLEEP=5

  CheckArgsExist 'SMTP_SERVER_ADDRESS SMTP_SERVER_FROM SMTP_SERVER_PORT'
  ncli cluster set-smtp-server port=${SMTP_SERVER_PORT} \
    address=${SMTP_SERVER_ADDRESS} from-email-address=${SMTP_SERVER_FROM}
  #log "sleep ${_SLEEP}..."; sleep ${_SLEEP}
  #log $(ncli cluster get-smtp-server | grep Status | grep success)
  log $(ncli cluster send-test-email recipient=${MY_EMAIL} \
    subject="PC_SMTP https://${PRISM_ADMIN}:${MY_PE_PASSWORD}@${MY_PC_HOST}:9440 Testing.")
  # local _TEST=$(curl ${CURL_HTTP_OPTS} --user ${PRISM_ADMIN}:${MY_PE_PASSWORD} -X POST -d '{
  #   "address":"${SMTP_SERVER_ADDRESS}","port":"${SMTP_SERVER_PORT}","username":null,"password":null,"secureMode":"NONE","fromEmailAddress":"${SMTP_SERVER_FROM}","emailStatus":null}' \
  #   https://localhost:9440/PrismGateway/services/rest/v1/cluster/smtp)
  # log "_TEST=|${_TEST}|"
}

function Enable_Flow {
  ## (API; Didn't work. Used nuclei instead)
  ## https://10.21.8.39:9440/api/nutanix/v3/services/microseg
  ## {"state":"ENABLE"}
  # To disable flow run the following on PC: nuclei microseg.disable

  log "Enable Nutanix Flow..."
  nuclei microseg.enable
  local _MICROSEG_STATUS=$(nuclei microseg.get_status)
  log "Result: $_MICROSEG_STATUS"
}

function PC_Project {
  local  _NAME=${MY_EMAIL%%@nutanix.com}.test
  local _COUNT=$(. /etc/profile.d/nutanix_env.sh \
    && nuclei project.list | grep ${_NAME} | wc --lines)
  if (( ${_COUNT} > 0 )); then
    nuclei project.delete ${_NAME} confirm=false
  else
    log "Warning: _COUNT=${_COUNT}"
  fi

  log "Creating ${_NAME}..."
  nuclei project.create name=${_NAME} description='test from NuCLeI!'
  local _UUID=$(. /etc/profile.d/nutanix_env.sh \
    && nuclei project.get ${_NAME} format=json \
    | ${HOME}/jq .metadata.project_reference.uuid | tr -d '"')
  log "${_NAME}.uuid = ${_UUID}"

    # - project.get mark.lavi.test
    # - project.update mark.lavi.test
    #     spec.resources.account_reference_list.kind= or .uuid
    #     spec.resources.default_subnet_reference.kind=
    #     spec.resources.environment_reference_list.kind=
    #     spec.resources.external_user_group_reference_list.kind=
    #     spec.resources.subnet_reference_list.kind=
    #     spec.resources.user_reference_list.kind=

    # {"spec":{"access_control_policy_list":[],"project_detail":{"name":"mark.lavi.test1","resources":{"external_user_group_reference_list":[],"user_reference_list":[],"environment_reference_list":[],"account_reference_list":[],"subnet_reference_list":[{"kind":"subnet","name":"Primary","uuid":"a4000fcd-df41-42d7-9ffe-f1ab964b2796"},{"kind":"subnet","name":"Secondary","uuid":"4689bc7f-61dd-4527-bc7a-9d737ae61322"}],"default_subnet_reference":{"kind":"subnet","uuid":"a4000fcd-df41-42d7-9ffe-f1ab964b2796"}},"description":"test from NuCLeI!"},"user_list":[],"user_group_list":[]},"api_version":"3.1","metadata":{"creation_time":"2018-06-22T03:54:59Z","spec_version":0,"kind":"project","last_update_time":"2018-06-22T03:55:00Z","uuid":"1be7f66a-5006-4061-b9d2-76caefedd298","categories":{},"owner_reference":{"kind":"user","name":"admin","uuid":"00000000-0000-0000-0000-000000000000"}}}
}

function PC_Update {
  log "This function not implemented yet."
  log "Download PC upgrade image: ${MY_PC_UPGRADE_URL##*/}"
  cd /home/nutanix/install && ./bin/cluster -i . -p upgrade
}

function Calm_Update {
  local _ATTEMPTS=12
  local _CALM_BIN=/usr/local/nutanix/epsilon
  local _CONTAINER
  local    _ERROR=19
  local     _LOOP=0
  local    _SLEEP=10
  local      _URL=http://${LDAP_HOST}:8080

  if [[ -e ${HOME}/epsilon.tar ]] && [[ -e ${HOME}/nucalm.tar ]]; then
    log "Bypassing download of updated containers."
  else
    remote_exec 'ssh' 'LDAP_SERVER' \
      'if [[ ! -e nucalm.tar ]]; then smbclient -I 10.21.249.12 \\\\pocfs\\images --user ${1} --command "prompt ; cd /Calm-EA/pc-'${MY_PC_VERSION}'/ ; mget *tar"; echo; ls -lH *tar ; fi' \
      'OPTIONAL'

    while true ; do
      (( _LOOP++ ))
      _TEST=$(curl ${CURL_HTTP_OPTS} ${_URL} \
        | tr -d \") # wonderful addition of "" around HTTP status code by cURL

      if (( ${_TEST} == 200 )); then
        log "Success reaching ${_URL}"
        break;
      elif (( ${_LOOP} > ${_ATTEMPTS} )); then
        log "Warning ${_ERROR} @${1}: Giving up after ${_LOOP} tries."
        return ${_ERROR}
      else
        log "@${1} ${_LOOP}/${_ATTEMPTS}=${_TEST}: sleep ${_SLEEP} seconds..."
        log "SSHPASS='nutanix/4u' sshpass -e ssh ${SSH_OPTS} ${LDAP_HOST} "\
          'python -m SimpleHTTPServer 8080 || python -m http.server 8080'
        sleep ${_SLEEP}
      fi
    done

    Download ${_URL}/epsilon.tar
    Download ${_URL}/nucalm.tar
    # remote_exec 'ssh' 'LDAP_SERVER' 'pkill python' 'OPTIONAL'
  fi

  if [[ -e ${HOME}/epsilon.tar ]] && [[ -e ${HOME}/nucalm.tar ]]; then
    ls -lh ${HOME}/*tar
    mkdir ${HOME}/calm.backup || true
    cp ${_CALM_BIN}/*tar ${HOME}/calm.backup/ \
    && genesis stop nucalm epsilon \
    && docker rm -f $(docker ps -aq) || true \
    && docker rmi -f $(docker images -q) || true \
    && cp ${HOME}/*tar ${_CALM_BIN}/ \
    && cluster start # ~75 seconds to start both containers

    for _CONTAINER in epsilon nucalm ; do
      local _TEST=0
      while [[ ${_TEST} < 1 ]]; do
        _TEST=$(docker ps -a | grep ${_CONTAINER} | grep -i healthy | wc --lines)
      done
    done
  fi
}

function AOS_Upload {
  local _AOS_UPGRADE=5.8.0.1
  AOS_META_URL=http://download.nutanix.com/releases/euphrates-${_AOS_UPGRADE}-metadata/v2/euphrates-${_AOS_UPGRADE}-metadata.json
  Download "${AOS_META_URL}"
  AOS_SRC_URL=$(cat euphrates-${_AOS_UPGRADE}-metadata.json \
    | jq -r .download_url_cdn)
  Download "${AOS_SRC_URL}"

  local _CHECKSUM=$(md5sum ${AOS_SRC_URL##*/} | awk '{print $1}')
  if [[ `cat ${AOS_META_URL##*/} | jq -r .hex_md5` != ${_CHECKSUM} ]]; then
    log "Error: md5sum ${_CHECKSUM} does't match on: ${AOS_SRC_URL##*/} removing and exit!"
    rm -f ${AOS_SRC_URL##*/}
    exit 2
  else
    log "AOS ${_AOS_UPGRADE} downloaded and passed MD5 checksum!"
  fi

  ncli software upload software-type=nos \
    meta-file-path=`pwd`/${AOS_META_URL##*/} file-path=`pwd`/${AOS_SRC_URL##*/}
}
#__main()____________

# Source Nutanix environment (PATH + aliases), then Workshop common routines + global variables
. /etc/profile.d/nutanix_env.sh
. common.lib.sh
. global.vars.sh

log `basename "$0"`": __main__: PID=$$"

Dependencies 'install' 'sshpass' && Dependencies 'install' 'jq' || exit 13

if [[ -z "${MY_PE_HOST}" ]]; then
  log "MY_PE_HOST unset, determining..."
  Determine_PE
  . global.vars.sh
fi

if [[ ! -z "${1}" ]]; then
  # hidden bonus
  log "Don't forget: $0 first.last@nutanixdc.local%password"
  Calm_Update && exit 0
fi

CheckArgsExist 'MY_EMAIL MY_PC_HOST MY_PE_PASSWORD MY_PC_VERSION'

ATTEMPTS=2
   SLEEP=10

log "Adding key to PC VMs..." && SSH_PubKey || true & # non-blocking, parallel suitable

PC_Init \
&& PC_UI \
&& PC_LDAP \
&& PC_SMTP \
&& SSP_Auth \
&& Enable_Calm \
&& Images \
&& Enable_Flow \
&& Check_Prism_API_Up 'PC'

PC_Project # TODO:50 PC_Project is a new function, non-blocking at end.

if (( $? == 0 )); then
  Dependencies 'remove' 'sshpass' && Dependencies 'remove' 'jq' \
  && log "PC = https://${MY_PC_HOST}:9440" \
  && log "${0} ran for ${SECONDS} seconds." \
  && log "$0: done!_____________________" && echo
else
  log "Error: failed to reach PC!"
  exit 19
fi
