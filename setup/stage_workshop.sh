#!/bin/bash
# -x
# use !/bin/bash -x to debug command substitution and evaluation instead of echo.

# For WORKSHOPS keyword mappings to scripts and variables:
# - use Calm | Citrix | Summit
# - use PC #.#

WORKSHOPS=(\
"Calm Workshop (AOS/AHV PC 5.8.x)" \
"Calm Workshop (AOS/AHV PC 5.7.x)" \
"Calm Workshop (AOS/AHV PC 5.6.x)" \
"Citrix Desktop on AHV Workshop (AOS/AHV 5.6)" \
#"Tech Summit 2018" \
) # Adjust function stage_clusters for mappings as needed

function stage_clusters {
  # Adjust as needed with $WORKSHOPS
  # Send configuration scripts to remote clusters and execute Prism Element script
  Dependencies 'install' 'sshpass'

  local _WORKSHOP=${WORKSHOPS[$((${WORKSHOP_NUM}-1))]}
  log "WORKSHOP #${WORKSHOP_NUM} = ${_WORKSHOP}"

  # Map to latest and greatest version of each point release
  if (( $(echo ${_WORKSHOP} | grep -i "PC 5.6" | wc -l) > 0 )); then
    MY_PC_VERSION=5.6.1
  elif (( $(echo ${_WORKSHOP} | grep -i "PC 5.7" | wc -l) > 0 )); then
    MY_PC_VERSION=5.7.1
  elif (( $(echo ${_WORKSHOP} | grep -i "PC 5.8" | wc -l) > 0 )); then
    MY_PC_VERSION=5.8.2
  fi

  # Map to staging scripts
  if (( $(echo ${_WORKSHOP} | grep -i Calm | wc -l) > 0 )); then
    PE_CONFIG=stage_calmhow.sh
    PC_CONFIG=stage_calmhow_pc.sh
  fi
  if (( $(echo ${_WORKSHOP} | grep -i Citrix | wc -l) > 0 )); then
    PE_CONFIG=stage_citrixhow.sh
    PC_CONFIG=stage_citrixhow_pc.sh
  fi
  if (( $(echo ${_WORKSHOP} | grep -i Summit | wc -l) > 0 )); then
    PE_CONFIG=stage_ts18.sh
    PC_CONFIG=stage_ts18_pc.sh
  fi

  if [[ ${CLUSTER_LIST} == '-' ]]; then
    echo "Login to see tasks in flight via https://${PRISM_ADMIN}:${MY_PE_PASSWORD}@${MY_PE_HOST}:9440"
    get_configuration
    cd scripts && eval "${CONFIGURATION} ./${PE_CONFIG}" #>> ${HOME}/${PE_CONFIG%%.sh}.log 2>&1
  else
    for MY_LINE in `cat ${CLUSTER_LIST} | grep -v ^#`
    do
      set -f
             _FIELDS=(${MY_LINE//|/ })
          MY_PE_HOST=${_FIELDS[0]}
      MY_PE_PASSWORD=${_FIELDS[1]}
            MY_EMAIL=${_FIELDS[2]}

      get_configuration

      . scripts/global.vars.sh # re-import for relative settings

      Check_Prism_API_Up 'PE' 60

      if [[ -d cache ]]; then
        #TODO:60 proper cache detection and downloads
        local _DEPENDENCIES='jq-linux64 sshpass-1.06-2.el7.x86_64.rpm'
        log "Sending cached dependencies (optional)..."
        pushd cache \
          && remote_exec 'SCP' 'PE' "${_DEPENDENCIES}" 'OPTIONAL' \
          && popd
      fi

      if (( $? == 0 )) ; then
        log "Sending configuration script(s) to PE@${MY_PE_HOST}"
      else
        log "Error: Can't reach PE@${MY_PE_HOST}, are you on VPN?"
        exit 15
      fi

      pushd scripts \
        && remote_exec 'SCP' 'PE' "common.lib.sh global.vars.sh ${PE_CONFIG} ${PC_CONFIG}" \
        && popd

      # For Calm container updates...
      if [[ -d cache/pc-${MY_PC_VERSION}/ ]]; then
        log "Uploading PC updates in background..."
        pushd cache/pc-${MY_PC_VERSION} \
        && pkill scp || true
        for _CONTAINER in epsilon nucalm ; do \
          if [[ -f ${_CONTAINER}.tar ]]; then \
            remote_exec 'SCP' 'PE' ${_CONTAINER}.tar 'OPTIONAL' & \
          fi
        done
        popd
      else
        log "No PC updates found in cache/pc-${MY_PC_VERSION}/"
      fi

      SSHKEY=${HOME}/.ssh/id_rsa.pub
      if [[ -f ${SSHKEY} ]]; then
        log "Sending ${SSHKEY} for additon to cluster..."
        remote_exec 'SCP' 'PE' ${SSHKEY} 'OPTIONAL'
      fi

      log "Remote execution configuration script on PE@${MY_PE_HOST}"
      remote_exec 'SSH' 'PE' "${CONFIGURATION} nohup bash /home/nutanix/${PE_CONFIG} >> ${PE_CONFIG%%.sh}.log 2>&1 &"

      cat <<EOM

  Cluster automation progress for ${_WORKSHOP} can be monitored via Prism Element and Central.

  If your SSH key has been uploaded to Prism > Gear > Cluster Lockdown,
  the following will fail silently, use ssh nutanix@{PE|PC} instead.

  $ SSHPASS='${MY_PE_PASSWORD}' sshpass -e ssh ${SSH_OPTS} \\
      nutanix@${MY_PE_HOST} 'date; tail -f ${PE_CONFIG%%.sh}.log'
    You can login to PE to see tasks in flight and eventual PC registration:
    https://${PRISM_ADMIN}:${MY_PE_PASSWORD}@${MY_PE_HOST}:9440/

  $ SSHPASS='nutanix/4u' sshpass -e ssh ${SSH_OPTS} \\
      nutanix@${MY_PC_HOST} 'date; tail -f ${PC_CONFIG%%.sh}.log'
    https://${PRISM_ADMIN}@${MY_PC_HOST}:9440/

EOM
    done

  fi
  log "${0} has run for ${SECONDS} seconds..."
  exit
}

function get_configuration {
  CONFIGURATION="MY_EMAIL=${MY_EMAIL} MY_PE_HOST=${MY_PE_HOST} PRISM_ADMIN=${PRISM_ADMIN} MY_PE_PASSWORD=${MY_PE_PASSWORD} MY_PC_VERSION=${MY_PC_VERSION}"
}

function validate_clusters {
  for MY_LINE in `cat ${CLUSTER_LIST} | grep -v ^#`
  do
    set -f
             array=(${MY_LINE//|/ })
        MY_PE_HOST=${array[0]}
    MY_PE_PASSWORD=${array[1]}

    Check_Prism_API_Up 'PE'
    if (( $? == 0 )) ; then
      log "Success: execute PE API on ${MY_PE_HOST}"
    else
      log "Failure: cannot validate PE API on ${MY_PE_HOST}"
    fi
  done
}

function script_usage {
  cat << EOF

See README.md and guidebook.md for more information.

    Interactive Usage: $0
Non-interactive Usage: $0 -f [${_CLUSTER_FILE}] -w [workshop_number]

Available Workshops:
EOF

  for (( i = 0; i < ${#WORKSHOPS[@]}-${NONWORKSHOPS}; i++ )); do
    let OFFBYONE=$i+1
    echo "${OFFBYONE} = ${WORKSHOPS[$i]}"
  done

  exit
}

function get_file {
  if [[ "${CLUSTER_LIST}" != '-' ]]; then
    echo
    read -p "$_CLUSTER_FILE: " CLUSTER_LIST # Prompt user

    if [[ ! -f "${CLUSTER_LIST}" ]]; then
      _ERROR=55
      echo "Warning ${_ERROR}: file not found = ${CLUSTER_LIST}"
      get_file
    fi
  fi

  echo
  select_workshop
}

function select_workshop {
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
          if [[ ${WORKSHOPS[$i]} == ${WORKSHOP} ]]; then
            let WORKSHOP_NUM=$i+1
          fi
        done

        if [[ ${WORKSHOP_NUM} == "" ]]; then
          echo -e "\nInvalid entry = ${WORKSHOP}, please try again."
        else
          echo "Matched!"
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
        echo "Error: file not found = ${OPTARG}"
        script_usage
      fi
      ;;
    w )
      if [[ $(($OPTARG)) > 0 ]] \
      && [[ $(($OPTARG)) < $((${#WORKSHOPS[@]}-${NONWORKSHOPS}+1)) ]]; then
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
elif [[ -z ${CLUSTER_LIST} ]]; then
  log "Error:|${CLUSTER_LIST}| missing ${_CLUSTER_FILE} argument."
  script_usage
elif [[ -n ${WORKSHOP_NUM} ]]; then
  log "Error: missing workshop number argument."
  script_usage
elif [[ ${WORKSHOPS[${WORKSHOP_NUM}]} == ${_VALIDATE} ]]; then
  validate_clusters
else
  get_file # If no command line arguments, start interactive session
fi
