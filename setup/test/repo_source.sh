#!/usr/bin/env bash

. ../scripts/common.lib.sh
. ../scripts/global.vars.sh

log "__AutoDC__"
unset SOURCE_URL
repo_source AUTODC_REPOS[@]
log "SOURCE_URL=${SOURCE_URL}"

log "__SSHPass__"
unset SOURCE_URL
_sshpass_pkg=${SSHPASS_REPOS[0]##*/}
repo_source SSHPASS_REPOS[@] ${_sshpass_pkg}
log "SOURCE_URL=${SOURCE_URL}"

log "__jq__"
unset SOURCE_URL
_jq_pkg=${JQ_REPOS[0]##*/}
repo_source JQ_REPOS[@] ${_jq_pkg}
log "SOURCE_URL=${SOURCE_URL}"

log "__qcow2 Images__"
for _image in "${QCOW2_IMAGES[@]}" ; do
  unset SOURCE_URL
  log "DEBUG: ${_image} image"
  repo_source QCOW2_REPOS[@] "${_image}"
  log "SOURCE_URL=${SOURCE_URL}"
done
