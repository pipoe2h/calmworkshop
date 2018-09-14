#!/usr/bin/env bash

# Example use:
# curl --remote-name --location https://raw.githubusercontent.com/mlavi/stageworkshop/master/bootstrap.sh && MY_EMAIL=mark.lavi sh ${_##*/}

. /etc/profile.d/nutanix_env.sh

CLUSTER_NAME=' '
CLUSTER_NAME+=$(ncli cluster get-params | grep 'Cluster Name' | \
       awk -F: '{print $2}' | tr -d '[:space:]')
EMAIL_DOMAIN=nutanix.com
         URL=https://github.com/mlavi/stageworkshop/archive/master.zip

if [[ -z ${MY_PE_PASSWORD} ]]; then
  echo
  read -p "OPTIONAL: What is this cluster's admin username? [Default: admin] " PRISM_ADMIN
  if [[ -z ${PRISM_ADMIN} ]]; then
    PRISM_ADMIN=admin
  fi

  echo; echo '    Note: Password will not be displayed.'
  read -s -p "REQUIRED: What is this${CLUSTER_NAME} cluster's admin password? " -r _PW1 ; echo
  read -s -p " CONFIRM:             ${CLUSTER_NAME} cluster's admin password? " -r _PW2 ; echo

  if [[ ${_PW1} != ${_PW2} ]]; then
    _ERROR=1
    echo "Error ${_ERROR}: passwords do not match."
    exit ${_ERROR}
  else
    MY_PE_PASSWORD=${_PW1}
    unset _PW1 _PW2
  fi
fi

MY_PE_HOST=$(ncli cluster get-params | grep 'External IP' | \
  awk -F: '{print $2}' | tr -d '[:space:]')

if [[ -z ${MY_EMAIL} ]]; then
  echo "    Note: @${EMAIL_DOMAIN} will be added if domain omitted."
  read -p "REQUIRED: Email address for cluster admin? " MY_EMAIL
fi

_WC_ARG='--lines'
if [[ `uname -s` == "Darwin" ]]; then
  _WC_ARG='-l'
fi
if (( $(echo ${MY_EMAIL} | grep @ | wc ${_WC_ARG}) == 0 )); then
  MY_EMAIL+=@${EMAIL_DOMAIN}
fi

FILESPEC=(${URL//\// })
    REPO=${FILESPEC[((${#FILESPEC} - 3))]}
  BRANCH=$(echo ${URL##*/} | awk -F.zip '{print $1}')

if [[ ! -d ${REPO}-${BRANCH} ]]; then
  curl --remote-name --location ${URL} \
  && echo "Success: ${URL##*/}" \
  && unzip ${URL##*/}
fi

echo -e "\nStarting stage_workshop.sh for ${MY_EMAIL} with ${PRISM_ADMIN}:passwordNotShown@${MY_PE_HOST}...\n"

pushd ${REPO}-${BRANCH}/ \
  && chmod -R u+x *sh \
  &&  MY_EMAIL=${MY_EMAIL} \
    MY_PE_HOST=${MY_PE_HOST} \
   PRISM_ADMIN=${PRISM_ADMIN} \
MY_PE_PASSWORD=${MY_PE_PASSWORD} \
./stage_workshop.sh -f - \
  && popd

if [[ ${1} == 'clean' ]]; then
  echo "Cleaning up..."
  rm -rf ${URL##*/} ${0} ${REPO}-${BRANCH}/
fi
exit

determine if I'm on HPOC nw variant for a local URL
   local _HTTP_RANGE_ENABLED='--continue-at -'
