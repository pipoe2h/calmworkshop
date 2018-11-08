#!/usr/bin/env bash
# shellcheck disable=SC2034
          RELEASE=release.json
   PC_VERSION_DEV=5.9.1
PC_VERSION_STABLE=5.8.2
      PRISM_ADMIN=admin

          OCTET=(${MY_PE_HOST//./ }) # zero index
    HPOC_PREFIX=${OCTET[0]}.${OCTET[1]}.${OCTET[2]}
DATA_SERVICE_IP=${HPOC_PREFIX}.$((${OCTET[3]} + 1))
     MY_PC_HOST=${HPOC_PREFIX}.$((${OCTET[3]} + 2))

           MY_SP_NAME='SP01'
    MY_CONTAINER_NAME='Default'
MY_IMG_CONTAINER_NAME='Images'

HTTP_CACHE_HOST=localhost
HTTP_CACHE_PORT=8181

# Conventions for *_REPOS arrays, the URL must end with:
# - trailing slash (which imples _IMAGES argument to repo_source)
# - or full package filename.

# https://stedolan.github.io/jq/download/#checksums_and_signatures
     JQ_REPOS=(\
      'https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64' \
)
  QCOW2_REPOS=(\
   'http://10.21.250.221/images/ahv/techsummit/' \
      'https://s3.amazonaws.com/get-ahv-images/' \
)
 QCOW2_IMAGES=(\
  CentOS7.qcow2 \
  Windows2016.qcow2 \
  Windows2012R2.qcow2 \
  Windows10-1709.qcow2 \
  CentOS7.iso \
  Windows2016.iso \
  Windows2012R2.iso \
  Windows10.iso \
  Nutanix-VirtIO-1.1.3.iso \
)
# https://pkgs.org/download/sshpass
# https://sourceforge.net/projects/sshpass/files/sshpass/
  SSHPASS_REPOS=(\
   'http://mirror.centos.org/centos/7/extras/x86_64/Packages/sshpass-1.06-2.el7.x86_64.rpm' \
)

   AUTH_SERVER='AutoDC'  # TODO:160 refactor AUTH_SERVER choice to input file, set default here.
     AUTH_HOST=${HPOC_PREFIX}.$((${OCTET[3]} + 3))
     LDAP_PORT=389
 MY_DOMAIN_URL="ldaps://${AUTH_HOST}/"
MY_DOMAIN_FQDN='ntnxlab.local'
MY_DOMAIN_NAME='NTNXLAB'
MY_DOMAIN_USER='administrator@'${MY_DOMAIN_FQDN}
MY_DOMAIN_PASS='nutanix/4u'
MY_DOMAIN_ADMIN_GROUP='SSP Admins'
  AUTODC_REPOS=(\
   'http://10.21.250.221/images/ahv/techsummit/AutoDC.qcow2' \
   'https://s3.amazonaws.com/get-ahv-images/AutoDC-04282018.qcow2' \
   'nfs://pocfs.nutanixdc.local/images/CorpSE_Calm/autodc-2.0.qcow2' \
  # 'smb://pocfs.nutanixdc.local/images/CorpSE_Calm/autodc-2.0.qcow2' \
   'http://10.59.103.143:8000/autodc-2.0.qcow2' \
)

  MY_PRIMARY_NET_NAME='Primary'
  MY_PRIMARY_NET_VLAN='0'
MY_SECONDARY_NET_NAME='Secondary'
MY_SECONDARY_NET_VLAN="${OCTET[2]}1" # TODO:100 check this: what did Global Enablement mean?

# https://sewiki.nutanix.com/index.php/Hosted_POC_FAQ#I.27d_like_to_test_email_alert_functionality.2C_what_SMTP_server_can_I_use_on_Hosted_POC_clusters.3F
SMTP_SERVER_ADDRESS=nutanix-com.mail.protection.outlook.com
   SMTP_SERVER_FROM=NutanixHostedPOC@nutanix.com
   SMTP_SERVER_PORT=25

   ATTEMPTS=40
      SLEEP=60

     CURL_OPTS='--insecure --silent --show-error' # --verbose'
CURL_POST_OPTS="${CURL_OPTS} --max-time 5 --header Content-Type:application/json --header Accept:application/json --output /dev/null"
CURL_HTTP_OPTS="${CURL_POST_OPTS} --write-out %{http_code}"
      SSH_OPTS='-o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null'
     SSH_OPTS+=' -q' # -v'
