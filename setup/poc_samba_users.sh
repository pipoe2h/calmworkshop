#!/bin/bash

#remotely populate domain controller:
# export DC_IP='10.21.example.40' && scp poc*sh root@${DC_IP}: && ssh root@${DC_IP} "chmod a+x poc*sh; ./poc_samba_users.sh 50"

if [[ -z ${1} ]]; then
  COUNT=70
else
  COUNT=${1}
fi
GROUP_NAME='CalmAdmin'
  PASSWORD='nutanix/4u'

samba-tool group add ${GROUP_NAME}

for (( N = 1; N < COUNT ; N++ )); do
  if (( ${N} < 10 )) ; then
    ZERO_PADDED="0${N}"
  else
    ZERO_PADDED="${N}"
  fi

  samba-tool user add user${ZERO_PADDED} "${PASSWORD}" --use-username-as-cn --userou='CN=Users'
  samba-tool group addmembers ${GROUP_NAME} user${ZERO_PADDED}
  echo
done
