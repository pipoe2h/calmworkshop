#!/usr/bin/env bash

PRISM_ADMIN=admin
      octet=(${MY_PE_HOST//./ }) # zero index
HPOC_PREFIX=${octet[0]}.${octet[1]}.${octet[2]}
 MY_PC_HOST=${HPOC_PREFIX}.$((${octet[3]} + 2))

           MY_SP_NAME='SP01'
    MY_CONTAINER_NAME='Default'
MY_IMG_CONTAINER_NAME='Images'

   LDAP_SERVER='AutoDC'  # TODO:130 refactor LDAP_SERVER choice to input file, set default here.
     LDAP_HOST=${HPOC_PREFIX}.$((${octet[3]} + 3))
 MY_DOMAIN_URL="ldaps://${LDAP_HOST}/"
MY_DOMAIN_FQDN='ntnxlab.local'
MY_DOMAIN_NAME='NTNXLAB'
MY_DOMAIN_USER='administrator@'${MY_DOMAIN_FQDN}
MY_DOMAIN_PASS='nutanix/4u'
MY_DOMAIN_ADMIN_GROUP='SSP Admins'

  MY_PRIMARY_NET_NAME='Primary'
  MY_PRIMARY_NET_VLAN='0'
MY_SECONDARY_NET_NAME='Secondary'
MY_SECONDARY_NET_VLAN="${octet[2]}1" # TODO:70 check this: what did Global Enablement mean?

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
