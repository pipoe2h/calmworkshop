#!/usr/bin/env bash

# stageworkshop_pe kill && stageworkshop_w1 && stageworkshop_pe
# TODO: prompt for choice when more than one cluster
# TODO: scp?

. scripts/global.vars.sh

if [[ -e ${RELEASE} && "${1}" != 'quiet' ]]; then
  echo -e "Sourced stageworkshop.lib.sh, release: $(jq -r '.FullSemVer' ${RELEASE})\n \
    \tPrismCentralStable=${PC_VERSION_STABLE}\n \
    \t   PrismCentralDev=${PC_VERSION_DEV}"

  if [[ -z ${PC_VERSION} ]]; then
    PC_VERSION="Check stage_workshop.sh::stage_clusters() for the best known \
    choice since $(grep CommitDate ${RELEASE} | awk -F\" '{print $4}')."
  fi
fi

alias stageworkshop_w1='./stage_workshop.sh -f example_pocs.txt -w 1'
alias stageworkshop_w2='./stage_workshop.sh -f example_pocs.txt -w 2'

function stageworkshop_cache_stop() {
  echo "Killing service and tunnel:${HTTP_CACHE_PORT}"
  kill -9 $(pgrep -f ${HTTP_CACHE_PORT})
}

function stageworkshop_cache_start() {
  local _file
  local _bits=( \
    http://10.59.103.143:8000/autodc-2.0.qcow2 \
    http://download.nutanix.com/calm/CentOS-7-x86_64-GenericCloud-1801-01.qcow2 \
    http://download.nutanix.com/pc/one-click-pc-deployment/5.9.1/v1/euphrates-5.9.1-stable-prism_central_metadata.json \
  )
  #https://github.com/mlavi/stageworkshop/archive/master.zip
  #http://download.nutanix.com/pc/one-click-pc-deployment/5.9.1/euphrates-5.9.1-stable-prism_central.tar

  if [[ ! -d cache ]]; then
    mkdir cache
  fi
  pushd cache

  echo "Setting up http://localhost:${HTTP_CACHE_PORT}/ on cache directory..."
  python -m SimpleHTTPServer ${HTTP_CACHE_PORT} || python -m http.server ${HTTP_CACHE_PORT} &

  for _file in "${_bits[@]}"; do
    if [[ -e ${_file##*/} ]]; then
      echo "Cached: ${_file##*/}"
    else
      curl --remote-name --location --continue-at - ${_file}
    fi
  done

  stageworkshop_cluster ''

  echo "Setting up remote SSH tunnel on local and remote port ${HTTP_CACHE_PORT}..."
  #ServerAliveInterval 120
  SSHPASS=${MY_PE_PASSWORD} sshpass -e ssh ${SSH_OPTS} -nNT \
    -R ${HTTP_CACHE_PORT}:localhost:${HTTP_CACHE_PORT} ${NTNX_USER}@${PE_HOST} &

  popd
  echo -e "\nTo turn service and tunnel off: stageworkshop_cache_stop"

  ps -efww | grep ssh
  unset NTNX_USER PE_HOST PE_PASSWORD SSHPASS
  stageworkshop_chrome http://localhost:${HTTP_CACHE_PORT}
}

alias stageworkshop_chrome_pe='stageworkshop_chrome PE'
alias stageworkshop_chrome_pc='stageworkshop_chrome PC'

function stageworkshop_chrome() {
  local _url="${1}"
  stageworkshop_cluster ''

  case "${1}" in
    PC | pc)
      _url=https://${_octet[0]}.${_octet[1]}.${_octet[2]}.$((_octet[3] + 2)):9440
      ;;
    PE | pe)
      _url=https://${PE_HOST}:9440
      ;;
  esac
  unset NTNX_USER PE_HOST PE_PASSWORD SSHPASS

  if [[ `uname -s` == "Darwin" ]]; then
    open -a 'Google Chrome' ${_url}
  fi

}

function stageworkshop_cluster() {
  local   _cluster
  local    _fields
  local  _filespec
  export NTNX_USER=nutanix

  if [[ -n ${1} || ${1} == '' ]]; then
    _filespec=~/Documents/github.com/mlavi/stageworkshop/example_pocs.txt
  else
    _filespec="${1}"
    echo "INFO: Using cluster file: |${1}| ${_filespec}"
  fi

  echo -e "\nAssumptions:
    - Last uncommented cluster in: ${_filespec}
    -     ssh user authentication: ${NTNX_USER}\n"

  _cluster=$(grep --invert-match --regexp '^#' "${_filespec}" | tail --lines=1)
   _fields=(${_cluster//|/ })

  export        PE_HOST=${_fields[0]}
  export MY_PE_PASSWORD=${_fields[1]}
  export       MY_EMAIL=${_fields[2]}
  #echo "INFO|stageworkshop_cluster|PE_HOST=${PE_HOST} MY_PE_PASSWORD=${MY_PE_PASSWORD} NTNX_USER=${NTNX_USER}."
}

function stageworkshop_ssh() {
  stageworkshop_cluster ''

  local      _cmd
  local     _host
  local    _octet
  local _password=${MY_PE_PASSWORD}
  local     _user=${NTNX_USER}

  _octet=(${PE_HOST//./ }) # zero index

  case "${1}" in
    PC | pc)
      echo 'pkill -f calm ; tail -f stage_calmhow*log'
      echo "PC_VERSION=${PC_VERSION} MY_EMAIL=${MY_EMAIL} MY_PE_PASSWORD=${_password} ./stage_calmhow_pc.sh"
          _host=${_octet[0]}.${_octet[1]}.${_octet[2]}.$((_octet[3] + 2))
      _password='nutanix/4u'
      ;;
    PE | pe)
      _host=${PE_HOST}

      cat << EOF
OPTIONAL: cd stageworkshop-master
   CHECK: wget http://${HTTP_CACHE_HOST}:${HTTP_CACHE_PORT} -q -O-

pkill -f calm ; tail -f stage_calmhow*log
EOF

      echo 'rm -rf master.zip stage_calmhow.log stageworkshop-master/ && \'
      echo '  curl --remote-name --location https://raw.githubusercontent.com/mlavi/stageworkshop/master/bootstrap.sh \'
      echo '  && SOURCE=${_} 'MY_EMAIL=${MY_EMAIL} MY_PE_PASSWORD=${_password}' sh ${_##*/} \'
      echo '  && tail -f ~/stage_calmhow.log'
      echo -e "cd stageworkshop-master/scripts/ && \ \n MY_PE_HOST=${PE_HOST} MY_PE_PASSWORD=${_password} PC_VERSION=${PC_VERSION_DEV} MY_EMAIL=${MY_EMAIL} ./stage_calmhow.sh"
      ;;
    AUTH | auth | ldap)
      _password='nutanix/4u'
          _host=${_octet[0]}.${_octet[1]}.${_octet[2]}.$((_octet[3] + 3))
          _user=root
  esac
  #echo "INFO|stageworkshop_ssh|PE_HOST=${PE_HOST} MY_PE_PASSWORD=${MY_PE_PASSWORD} NTNX_USER=${NTNX_USER}."

  case "${2}" in
    log | logs)
      _cmd='date; tail -f stage_calmhow*log'
      ;;
    calm | inflight)
      _cmd='ps -efww | grep calm'
      ;;
    kill | stop)
      _cmd='ps -efww | grep calm ; pkill -f calm; ps -efww | grep calm'
      ;;
    *)
      _cmd="${2}"
      ;;
  esac

  echo "INFO: ${_host} $ ${_cmd}"
  SSHPASS="${_password}" sshpass -e ssh -q \
    -o StrictHostKeyChecking=no \
    -o GlobalKnownHostsFile=/dev/null \
    -o UserKnownHostsFile=/dev/null \
    ${_user}@"${_host}" "${_cmd}"

  unset NTNX_USER PE_HOST PE_PASSWORD SSHPASS
}

function stageworkshop_pe() {
  stageworkshop_ssh 'PE' "${1}"
}

function stageworkshop_pc() {
  stageworkshop_ssh 'PC' "${1}"
}

function stageworkshop_auth() {
  stageworkshop_ssh 'AUTH' "${1}"
}
