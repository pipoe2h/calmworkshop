#!/usr/bin/env bash
# use bash -x to debug command substitution and evaluation instead of echo.

# For WORKSHOPS keyword mappings to scripts and variables, please use:
# - Calm || Citrix || Summit
# - PC #.#
WORKSHOPS=(\
"Calm Workshop (AOS 5.5+/AHV PC 5.8.x) = Stable (AutoDC1)" \
"Calm Workshop (AOS 5.5+/AHV PC 5.9.x) = Development (AutoDC2)" \
# "Calm Workshop (AOS 5.5+/AHV PC 5.7.x)" \
# "Calm Workshop (AOS 5.5+/AHV PC 5.6.x)" \
"Citrix Desktop on AHV Workshop (AOS/AHV 5.6)" \
#"Tech Summit 2018" \
) # Adjust function stage_clusters for mappings as needed

function stage_clusters() {
  # Adjust map below as needed with $WORKSHOPS
  local      _cluster
  local    _container
  local _dependencies
  local       _fields
  local    _pe_config
  local    _pc_config
  local      _release
  local       _sshkey
  local     _workshop=${WORKSHOPS[$((${WORKSHOP_NUM}-1))]}

  # Map to latest and greatest of each point release
  # Metadata URLs MUST be specified in common.lib.sh function: NTNX_Download
  if (( $(echo ${_workshop} | grep -i "PC 5.9" | wc -l) > 0 )); then
    export PC_VERSION=5.9.1
  elif (( $(echo ${_workshop} | grep -i "PC 5.8" | wc -l) > 0 )); then
    export PC_VERSION=5.8.2
  elif (( $(echo ${_workshop} | grep -i "PC 5.7" | wc -l) > 0 )); then
    export PC_VERSION=5.7.1.1
  elif (( $(echo ${_workshop} | grep -i "PC 5.6" | wc -l) > 0 )); then
    export PC_VERSION=5.6.2
  fi

  # Map to staging scripts
  if (( $(echo ${_workshop} | grep -i Calm | wc -l) > 0 )); then
    _pe_config=stage_calmhow.sh
    _pc_config=stage_calmhow_pc.sh
  fi
  if (( $(echo ${_workshop} | grep -i Citrix | wc -l) > 0 )); then
    _pe_config=stage_citrixhow.sh
    _pc_config=stage_citrixhow_pc.sh
  fi
  if (( $(echo ${_workshop} | grep -i Summit | wc -l) > 0 )); then
    _pe_config=stage_ts18.sh
    _pc_config=stage_ts18_pc.sh
  fi

  Dependencies 'install' 'sshpass'

  log "WORKSHOP #${WORKSHOP_NUM} = ${_workshop} with PC-${PC_VERSION}"
  # Send configuration scripts to remote clusters and execute Prism Element script

  if [[ ${CLUSTER_LIST} == '-' ]]; then
    echo "Login to see tasks in flight via https://${PRISM_ADMIN}:${MY_PE_PASSWORD}@${MY_PE_HOST}:9440"
    get_configuration
    cd scripts && eval "${CONFIGURATION} ./${_pe_config}" >> ${HOME}/${_pe_config%%.sh}.log 2>&1 &
  else
    for _cluster in `cat ${CLUSTER_LIST} | grep -v ^#`
    do
      set -f
             _fields=(${_cluster//|/ })
          MY_PE_HOST=${_fields[0]}
      MY_PE_PASSWORD=${_fields[1]}
            MY_EMAIL=${_fields[2]}

      get_configuration

      . scripts/global.vars.sh # re-import for relative settings

      Check_Prism_API_Up 'PE' 60

      if [[ -d cache ]]; then
        #TODO:90 proper cache detection and downloads
        _dependencies="${JQ_PACKAGE} ${SSHPASS_PACKAGE}"
        log "Sending cached dependencies (optional)..."
        pushd cache \
          && remote_exec 'SCP' 'PE' "${_dependencies}" 'OPTIONAL' \
          && popd
      fi

      if (( $? == 0 )) ; then
        log "Sending configuration script(s) to PE@${MY_PE_HOST}"
      else
        _error=15
        log "Error ${_error}: Can't reach PE@${MY_PE_HOST}, are you on VPN?"
        exit ${_error}
      fi

      if [[ -e ${RELEASE} ]]; then
        log "Adding release version file to manifest."
        _release="../${RELEASE}"
      fi

      pushd scripts \
        && remote_exec 'SCP' 'PE' "common.lib.sh global.vars.sh ${_release} ${_pe_config} ${_pc_config}" \
        && popd

      # For Calm container updates...
      if [[ -d cache/pc-${PC_VERSION}/ ]]; then
        log "Uploading PC updates in background..."
        pushd cache/pc-${PC_VERSION} \
        && pkill scp || true
        for _container in epsilon nucalm ; do \
          if [[ -f ${_container}.tar ]]; then \
            remote_exec 'SCP' 'PE' ${_container}.tar 'OPTIONAL' & \
          fi
        done
        popd
      else
        log "No PC updates found in cache/pc-${PC_VERSION}/"
      fi

      _sshkey=${HOME}/.ssh/id_rsa.pub
      if [[ -f ${_sshkey} ]]; then
        log "Sending ${_sshkey} for additon to cluster..."
        remote_exec 'SCP' 'PE' ${_sshkey} 'OPTIONAL'
      fi

      log "Remote execution configuration script on PE@${MY_PE_HOST}"
      remote_exec 'SSH' 'PE' "${CONFIGURATION} nohup bash /home/nutanix/${_pe_config} >> ${_pe_config%%.sh}.log 2>&1 &"

      # shellcheck disable=SC2153
      cat <<EOM

  Cluster automation progress for ${_workshop} can be monitored via Prism Element and Central.

  If your SSH key has been uploaded to Prism > Gear > Cluster Lockdown,
  the following will fail silently, use ssh nutanix@{PE|PC} instead.

  $ SSHPASS='${MY_PE_PASSWORD}' sshpass -e ssh ${SSH_OPTS} \\
      nutanix@${MY_PE_HOST} 'date; tail -f ${_pe_config%%.sh}.log'
    You can login to PE to see tasks in flight and eventual PC registration:
    https://${PRISM_ADMIN}:${MY_PE_PASSWORD}@${MY_PE_HOST}:9440/

  $ SSHPASS='nutanix/4u' sshpass -e ssh ${SSH_OPTS} \\
      nutanix@${MY_PC_HOST} 'date; tail -f ${_pc_config%%.sh}.log'
    https://${PRISM_ADMIN}@${MY_PC_HOST}:9440/

EOM
    done

  fi
  finish
  exit
}

function get_configuration() {
  CONFIGURATION="MY_EMAIL=${MY_EMAIL} MY_PE_HOST=${MY_PE_HOST} PRISM_ADMIN=${PRISM_ADMIN} MY_PE_PASSWORD=${MY_PE_PASSWORD} PC_VERSION=${PC_VERSION}"
}

function validate_clusters() {
  local _cluster
  local  _fields

  for _cluster in `cat ${CLUSTER_LIST} | grep -v ^#`
  do
    set -f
           _fields=(${_cluster//|/ })
        MY_PE_HOST=${_fields[0]}
    MY_PE_PASSWORD=${_fields[1]}

    Check_Prism_API_Up 'PE'
    if (( $? == 0 )) ; then
      log "Success: execute PE API on ${MY_PE_HOST}"
    else
      log "Failure: cannot validate PE API on ${MY_PE_HOST}"
    fi
  done
}

function script_usage() {
  local _offbyone

  cat << EOF

See README.md and guidebook.md for more information.

    Interactive Usage: $0
Non-interactive Usage: $0 -f [${_CLUSTER_FILE}] -w [workshop_number]
Non-interactive Usage: MY_EMAIL=first.last@nutanix.com MY_PE_HOST=10.x.x.37 PRISM_ADMIN=admin MY_PE_PASSWORD=examplePW $0 -f -

Available Workshops:
EOF

  for (( i = 0; i < ${#WORKSHOPS[@]}-${NONWORKSHOPS}; i++ )); do
    let _offbyone=$i+1
    echo "${_offbyone} = ${WORKSHOPS[$i]}"
  done

  exit
}

function get_file() {
  local _error=55

  if [[ "${CLUSTER_LIST}" != '-' ]]; then
    echo
    read -p "$_CLUSTER_FILE: " CLUSTER_LIST # Prompt user

    if [[ ! -f "${CLUSTER_LIST}" ]]; then
      echo "Warning ${_error}: file not found = ${CLUSTER_LIST}"
      get_file
    fi
  fi

  echo
  select_workshop
}

function select_workshop() {
  # Get workshop selection from user, set script files to send to remote clusters
  PS3='Select an option: '
  select WORKSHOP in "${WORKSHOPS[@]}"
  do
    case $WORKSHOP in
      "Change ${_CLUSTER_FILE}")
        CLUSTER_LIST= # reset
        get_file
        break
        ;;
      "Validate Staged Clusters")
        validate_clusters
        break
        ;;
      "Quit")
        exit
        ;;
      *)
        for (( i = 0; i < ${#WORKSHOPS[@]}-${NONWORKSHOPS}; i++ )); do
          if [[ ${WORKSHOPS[$i]} == "${WORKSHOP}" ]]; then
            let WORKSHOP_NUM=$i+1
          fi
        done

        if [[ ${WORKSHOP_NUM} == "" ]]; then
          echo -e "\nInvalid entry = ${WORKSHOP}, please try again."
        else
          #log "Matched: workshop ${WORKSHOP}!"
          break
        fi
        ;;
    esac
  done

  echo -e "\nAre you sure you want to stage ${WORKSHOP} to the cluster(s) provided? \
    \nYour only 'undo' option is running Foundation on your cluster(s) again."
  read -p '(Y/N)' -n 1 -r

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    stage_clusters
  else
    echo -e "\nCome back soon!"
  fi
}

#__main__

# Source Workshop common routines + global variables
. scripts/common.lib.sh
. scripts/global.vars.sh
begin

    _VALIDATE='Validate Staged Clusters'
_CLUSTER_FILE='Cluster Input File'
 CLUSTER_LIST=

# NONWORKSHOPS appended to end of WORKSHOPS
             WORKSHOP_COUNT=${#WORKSHOPS[@]}
WORKSHOPS[${#WORKSHOPS[@]}]="Change ${_CLUSTER_FILE}"
WORKSHOPS[${#WORKSHOPS[@]}]=${_VALIDATE}
WORKSHOPS[${#WORKSHOPS[@]}]="Quit"
           let NONWORKSHOPS=${#WORKSHOPS[@]}-${WORKSHOP_COUNT}

# Check if file passed via command line, otherwise prompt for cluster list file
while getopts "f:w:\?" opt; do

  if [[ ${DEBUG} ]]; then
    log "Checking option: ${opt} with arguent ${OPTARG}"
  fi

  case ${opt} in
    f )
      if [[ ${OPTARG} == '-' ]]; then
        log "${_CLUSTER_FILE} override, checking environment variables..."
        CheckArgsExist 'MY_EMAIL MY_PE_HOST MY_PE_PASSWORD'
        CLUSTER_LIST=${OPTARG}
      elif [[ -f ${OPTARG} ]]; then
        CLUSTER_LIST=${OPTARG}
      else
        echo "Error: file not $(($OPTARG)) < $((${#WORKSHOPS[@]}-${NONWORKSHOPS}+1)) found = ${OPTARG}"
        script_usage
      fi
      ;;
    w )
      if (( $(($OPTARG)) > 0 )) \
      && (( $(($OPTARG)) < $((${#WORKSHOPS[@]}-${NONWORKSHOPS}+1)) )); then
        WORKSHOP_NUM=${OPTARG}
      else
        echo "Error: workshop not found = ${OPTARG}"
        script_usage
      fi
      ;;
    \? )
      script_usage
      ;;
  esac
done
shift $((OPTIND -1))

if [[ -n ${CLUSTER_LIST} && -n ${WORKSHOP_NUM} ]]; then
  stage_clusters
elif [[ -n ${WORKSHOP_NUM} ]]; then
  log "Error: missing workshop number argument."
  script_usage
elif [[ ${WORKSHOPS[${WORKSHOP_NUM}]} == "${_VALIDATE}" ]]; then
  validate_clusters
else
  log "Warning: missing ${_CLUSTER_FILE} argument."
  get_file # If no command line arguments, start interactive session
fi
