#!/usr/bin/env bash

if [[ ${USER} != 'root' ]]; then
  echo "Error in assumption: execute as user root."
  exit 1
fi

if [[ -z ${_autodc_conf} || -z ${_autodc_patch} ]]; then
  echo "Warning: _autodc_* environment variables not populated."
   _autodc_conf=/etc/samba/smb.conf
  _autodc_patch='ldap server require strong auth = no'
else
  echo "_autodc_conf=${_autodc_conf} _autodc_patch=${_autodc_patch}"
fi

if (( $(grep "${_autodc_patch}" ${_autodc_conf} | wc --lines) == 0 )); then
  echo "Patching ${_autodc_conf}"
  cat ${_autodc_conf} | sed "s/\\[global\\]/\\[global\\]\n\t${_autodc_patch}/" \
    > ${_autodc_conf}.patched && mv ${_autodc_conf}.patched ${_autodc_conf}

  echo "Restarting Samba..."
  service smbd restart && sleep 2
else
  echo "No AutoDC patch needed."
fi

service smbd status

exit

curl --remote-name --location \
https://raw.githubusercontent.com/mlavi/stageworkshop/master/autodc/autodc-v1-patch.sh \
  && export _autodc_conf=${_autodc_conf} \
  && export _autodc_patch=\"${_autodc_patch}\" \
  && bash ${_##*/}
