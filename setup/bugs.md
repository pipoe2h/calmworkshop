# Push Button Calm: Bugs, Priorities, Notes #

- BUG = PC 5.9 authentication regression
  - https://jira.nutanix.com/browse/ENG-180716 = "Invalid service account details" error message is incorrect
    - Fix scheduled for PC 5.10.1
  - Workaround = [AutoDC: Version2](autodc/README.md#Version2)
    - TODO: Validate

- BUG = all stage_calmhow_pc.sh service timeout detect/retry
  - 2018-10-24 21:54:23|14165|Determine_PE|Warning: expect errors on lines 1-2, due to non-JSON outputs by nuclei...
  E1024 21:54:24.142107   14369 jwt.go:35] ZK session is nil
  2018/10/24 21:54:24 Failed to connect to the server: websocket.Dial ws://127.0.0.1:9444/icli: bad status: 403

- FEATURE = Darksite/cache:
  - Ideal to do this on a CVM, but you can prepare by downloading all of the bits in advance.
   The goal is to get everything onto the CVM if there’s room.
   If not, get it onto a fileserver that the CVM can access, even via SCP/SSH.
  - Download the push button Calm archive, unarchive, create a cache directory inside:
  wget https://github.com/mlavi/stageworkshop/archive/master.zip && \
  unzip master.zip && pushd stageworkshop-master && mkdir cache && cd ${_}
  -  Put everything else below in this cache directory and contact me.
    - AutoDC: http://10.59.103.143:8000/autodc-2.0.qcow2
    - CentOS 7.4 image: http://download.nutanix.com/calm/CentOS-7-x86_64-GenericCloud-1801-01.qcow2
    - PC-5.9.1 metadata and bits:
      - http://download.nutanix.com/pc/one-click-pc-deployment/5.9.1/v1/euphrates-5.9.1-stable-prism_central_metadata.json
      - http://download.nutanix.com/pc/one-click-pc-deployment/5.9.1/euphrates-5.9.1-stable-prism_central.tar
    - jq-1.5: https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
    - sshpass: http://mirror.centos.org/centos/7/extras/x86_64/Packages/sshpass-1.06-2.el7.x86_64.rpm
    # OPTIONAL rolling: http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2

- Feature = improve MKTG+SRE cluster automation
  - Louie: https://confluence.eng.nutanix.com:8443/display/LABS/Internal+Networks
  - detect HPOC networks to favor local URLs?
  - Marketing cluster = 10.20, HPOC=10.21: add MKT DNS? remove secondary nw

- Ongoing = refactor URLs into global.vars.sh?
  - ````egrep http *sh */*sh \
    --exclude autodc*sh --exclude hooks*sh --exclude stage_citrixhow* \
    --exclude vmdisk2image-pc.sh --exclude global.vars.sh \
  | grep -v -i -e localhost -e 127.0.0.1 -e _HOST -e _http_ \
    -e download.nutanix.com -e portal.nutanix.com -e python -e github -e '#' \
  > http.txt````
  - download 403 detection: authentication unauthorized

# Backlog #

- CI/CD pipeline demo
- LAMP v2 application improvements (reboot nice to have)
- Calm videos/spreadsheet
- Multi product demo
- Projects: update default or create new project
- PC_Init|Reset PC password to PE password, must be done by nci@PC, not API or on PE
  Error: Password requirements: Should be at least 8 characters long. Should have at least 1 lowercase character(s). Should have at least 1 uppercase character(s). Should have at least 1 digit(s). Should have at least 1 special character(s). Should differ by at least 4 characters from previous password. Should not be from last 5 passwords. Should not have more than 2 same consecutive character(s). Should not be a dictionary word or too simplistic/systematic. Should should have at least one character belonging to 4 out of the 4 supported classes (lowercase, uppercase, digits, special characters).
  2018-10-02 10:56:27|92834|PC_Init|Warning: password not reset: 0.#
- Fix role mappings, logins on PE, PC
  - PE, PC: use RBAC user for APIs, etc.: cluster Admin
  - improve/run autodc/add_group_and_users.sh
  - adminuser01@ntnxlab.local (password = nutanix/4u) can’t login to PE.
    “You are not authorized to access Prism. Please contact the Nutanix administrator.”
    add user01@ntnxlab.local to role mapping, same error as above.
- OpenLDAP is now supported for Self Service on Prism Central: ENG-126217

- TODO: Add link: https://drt-it-github-prod-1.eng.nutanix.com/akim-sissaoui/calm_aws_setup_blueprint/blob/master/Action%20Create%20Project/3-Create%20AWS%20Calm%20Entry
- TODO: check remote file for cache, containers, images before uploading and skip when OPTIONAL
- nuclei (run local from container?)
  - version.get # gives API 3.1 and AOS 5.7.0.1 (bug!)
    - vs: cat /etc/nutanix/release_version
  - project.create name=mark.lavi.test \
    description='test_from NuClei!'
  - project.get mark.lavi.test
  - project.update mark.lavi.test
      spec.resources.account_reference_list.kind= or .uuid
      spec.resources.default_subnet_reference.kind=
      spec.resources.environment_reference_list.kind=
      spec.resources.external_user_group_reference_list.kind=
      spec.resources.subnet_reference_list.kind=
      spec.resources.user_reference_list.kind=

      resources:
        account_reference_list: []
        environment_reference_list: []
        external_user_group_reference_list: []
        is_default: false
        resource_domain:
          resources: []
        subnet_reference_list: []
        user_reference_list: []
  - nuclei authconfig (run local from container?) See notes#nuceli section, below.
- TODO: (localize?) and upload blueprint via nuclei (see unit tests)?
- TODO: Default project environment set, enable marketplace item, launch!
- TODO: Enable multiple cloud account settings, then environments, then marketplace launch
- TODO: PE, PC: clear our warnings: resolve/ack issues for cleanliness?

- TODO: Calm 5.8 bootcamp labs and 5.5-6 bugs
  - https://github.com/nutanixworkshops/introcalm
  vs. https://github.com/mlavi/calm_workshop
  - file Calm bugs from guide
- Boxcutter for AHV:
  - extend scripts/vmdisk2image-pc.sh to
    - https://qemu.weilnetz.de/doc/qemu-doc.html#disk_005fimages_005fssh
      qemu-system-x86_64 -drive file=ssh://[user@]server[:port]/path[?host_key_check=host_key_check]
    - download (NFS?)/export image
    - upload/import image
  - drive into Jenkinsfile pipeline job
    - periodic runs: weekly?
  - Base images/boxes: https://github.com/chef/bento
- Refactor 10.21 out further: mostly done! move to bats?
- refactor out all passwords, hardcoded values to variables
  - SSP Admins
- Create adminuser2, assign privs, use it instead of base admin user (drop privs/delete at end?)
- ncli rsyslog
- Add widget Deployed Applications to (default) dashboard

- FEATURE: improved software engineering
  - https://githooks.com/
    - https://github.com/nkantar/Autohook
    - https://pre-commit.com/
      - brew install pre-commit
    - https://github.com/rycus86/githooks
  - Add (git)version/release to each script (assembly?) for github archive cache
    - https://semver.org/
      - https://guides.github.com/introduction/flow/index.html
      - https://github.com/GitTools/GitVersion
        - https://gitversion.readthedocs.io/en/stable/usage/command-line/
        - brew install gitversion
        - GitVersion /showConfig
      - sudo apt-get install mono-complete
        - do not: sudo apt-get install libcurl3 # removes curl libcurl4
      - Download dotnet4 zip archive
      - put on mono-path?
      - Investigate https://hub.docker.com/r/gittools/gitversion-fullfx/
        - docker pull gittools/gitversion-fullfx:linux
        - docker run --rm -v "$(pwd):/repo" gittools/gitversion-fullfx:linux{-version} /repo
      - gitversion | tee gitversion.json | jq -r .FullSemVer
      - ````ls -l *json && echo _GV=${_GV}````
      - ````_GV=gitversion.json ; rm -f ${_GV} \
      && gitversion | tee ${_GV} | grep FullSemVer | awk -F\" '{print $4}' && unset _GV````
      - https://blog.ngeor.com/2017/12/19/semantic-versioning-with-gitversion.html
    - versus https://github.com/markchalloner/git-semver
  - ~/Documents/github.com/ideadevice/calm/src/calm/tests/qa/docs
    = https://github.com/ideadevice/calm/tree/master/src/calm/tests/qa/docs
  - start a feature branch
  - syslog format: INFO|DEBUG|etc.
    - https://en.wikipedia.org/wiki/Syslog#Severity_level
  - Per Google shell style guide:
    - refactor function names to lowercase: https://google.github.io/styleguide/shell.xml?showone=Function_Names#Function_Names
  - http://jake.ginnivan.net/blog/2014/05/25/simple-versioning-and-release-notes/
    - https://github.com/GitTools/GitReleaseNotes
# Bash test framework for unit tests and on blueprints?
  - https://kitchen.ci/ which can do spec, BATS, etc. = https://github.com/test-kitchen/test-kitchen
    - https://kitchen.ci/docs/getting-started/writing-test
    - https://serverspec.org/ DSL Spec TDD
    - http://rspec.info/ Ruby TDD
    - inspec
      - more compliance from supermarket
      - https://dev-sec.io/features.html#os-hardening
      - https://www.cisecurity.org/cis-benchmarks/
    - https://en.wikipedia.org/wiki/ERuby
    - https://www.engineyard.com/blog/bats-test-command-line-tools
    - https://medium.com/@pimterry/testing-your-shell-scripts-with-bats-abfca9bdc5b9
      - http://ohmyz.sh/
      - https://github.com/jakubroztocil/httpie#scripting
      - https://github.com/pimterry/git-confirm
  - BATS https://github.com/bats-core/bats-core
  - https://invent.life/project/bash-infinity-framework
  - Runit/rundeck? http://bashdb.sourceforge.net/
  - Tests:
    - external URLs working (PC x, sshpass, jq, autodc, etc.)
    - userX login to PE, PC
    - userX new project, upload, run blueprint
    - GOOD: user01@ntnxlab.local auth test fine@PE, bats?

# AutoDC:
  - GOOD:
    - NTNXLAB, ntnxlab.local, root:nutanix/4u
    - samba --version Version 4.2.14-Debian
    - https://wiki.archlinux.org/index.php/samba
    - https://gitlab.com/mlavi/alpine-dc (fork)
  - yum install samba-ldap
    - https://help.ubuntu.com/lts/serverguide/samba-ldap.html.en
  - Move AutoDC to DHCP? and adjust DNS for SRE HPOC subnets?

# DOCUMENTATION:
  - review, refactor & migrate to bugs.txt: TODO, TOFIX comments
  - Insure exit codes unique/consistent, error messages consistent

# OPTIMIZATION:
  - Upload AutoDC image in parallel with PC.tar
  - restore http_resume check/attempt
  - create cache, use cache, propagate cache to PC, fall back to global

# Notes #

## Citations for other Calm automation ##

- https://drt-it-github-prod-1.eng.nutanix.com/sylvain-huguet/auto-hpoc
- One more: @anthony.c?
- https://gitlab.com/Chandru.tkc/Serviceability_shared/
  - pc-automate/installpc.py
  - 24:     "heartbeat":    "/PrismGateway/services/rest/v1/heartbeat",
  - 326: def validate_cluster(entity):
  - 500: def add_network_to_project(name,directory_uuid):

## Push Button Calm #

- https://github.com/mlavi/stageworkshop/blob/master/guidebook.md
- MP4 Video = 292MB: https://drive.google.com/open?id=1AfIWDff-mlvwth_lKv9DG4x-vi0ZsWij
 ~11 minute screencast overview of the 70 minute journey from Foundation
  to Calm running a blueprint: most of it is waiting for foundation and PC download/upload/deploy.
- Social coding: https://github.com/nutanixworkshops/stageworkshop/pull/1
- Biggest pain:
  - finding a HPOC
  - second biggest pain: keeping it for more than a few hours except on the weekend.
  - third biggest pain: coding in Bash :slightly_smiling_face: it makes you miss even script kiddie programming languages!

## NuCLeI ##

https://jira.nutanix.com/browse/ENG-78322 <nuclei>
````app_blueprint
availability_zone
available_extension
available_extension_images
catalog_item
category
certificate
changed_regions
client_auth
cloud_credentials
cluster
container
core                          CLI control.
diag                          Diagnostic tools.
directory_service
disk
docker_image
docker_registry
exit                          Exits the CLI.
extension
get                           Gets the current value of the given configuration options.
help                          Provides help text for the named object.
host
image
network_function_chain
network_security_rule
oauth_client
oauth_token
permission
project
protection_rule
quit                          Exits the CLI.
recovery_plan
recovery_plan_job
remote_connection
report_config
report_instance
role
set                           Sets the value of the given configuration options.
ssh_user
subnet
user
version                       NuCLEI Version Information.
virtual_network
vm
vm_backup
vm_snapshot
volume_group
volume_group_backup
volume_group_snapshot
webhook
````

### nuclei authconfig (run local from container?) ####

````list | ls
edit | update
remove | rm
list-directory | ls-directory
create-directory | add-directory
edit-directory | update-directory
remove-directory | rm-directory
list-role-mappings | ls-role-mappings
delete-role-mapping
add-role-mapping
add-to-role-mapping-values
remove-from-role-mapping-values
get-directory-values-by-type
test-ldap-connection
````

## Image Uploading ##
TOFIX:
- https://jira.nutanix.com/browse/FEAT-7112
- https://jira.nutanix.com/browse/ENG-115366
once PC image service takes control, rejects PE image uploads. Move to PC, not critical path.

KB 4892 = https://portal.nutanix.com/#/page/kbs/details?targetId=kA00e000000XePyCAK
v3 API = http://developer.nutanix.com/reference/prism_central/v3/#images two steps:

1. POST /images to create image metadata and get UUID, see logs/spec-image.json
2. PUT images/uuid/file: upload uuid, body, checksum and checksum type: sha1, sha256
or nuclei, only on PCVM or in container

## File servers for container updates ##

- https://sewiki.nutanix.com/index.php/Hosted_Proof_of_Concept_(HPOC)#What_you_get_with_each_reservation
- https://sewiki.nutanix.com/index.php/Hosted_Proof_of_Concept_(HPOC)#Lab_Resources
- https://sewiki.nutanix.com/index.php/HPOC_Access_Instructions#FTP
  - \\lab-ftp\ftp
  - smb://hpoc-ftp/ = \\hpoc-ftp\ftp
  - ftp://nutanix:nutanix/4u@hostedpoc.nutanix.com/
  - smb://pocfs/    = \\pocfs\iso\ and \images\
  - smb://pocfs.nutanixdc.local use: auth
    - WIN> nslookup pocfs.nutanixdc.local
    - smbclient -I 10.21.249.12 \\\\pocfs\\images \
      --user mark.lavi@nutanixdc.local --command "prompt ; cd /Calm-EA/pc-5.7.1/ ; mget *tar"
  - smb://hpoc-afs/ = \\hpoc-afs\se\
    - smbclient \\\\hpoc-afs\\se\\ --user mark.lavi@nutanixdc.local --debuglevel=10
    - WIN> nslookup hpoc-afs.nutanixdc.local
    10.21.249.41-3
    - smbclient -I 10.21.249.41 \\\\hpoc-afs\\se\\ --user mark.lavi@nutanixdc.local
  - smb://NTNX-HPOC-AFS-3.NUTANIXDC.LOCAL
  default password = welcome123
  - https://ubuntuswitch.wordpress.com/2010/02/05/nautilus-slow-network-or-network-does-not-work/
- smb-client vs cifs?
  - https://www.tldp.org/HOWTO/SMB-HOWTO-8.html
  - https://www.samba.org/samba/docs/current/man-html/smbclient.1.html
  - https://linux-cifs.samba.org/
    - https://pserver.samba.org/samba/ftp/cifs-cvs/linux-cifs-client-guide.pdf
    - https://serverfault.com/questions/609365/cifs-mount-in-fstab-succeeds-on-ip-fails-on-hostname-written-in-etc-hosts
      - sudo apt-get install cifs-utils
      - yum install cifs-utils
        man mount.cifs
        USER=mark.lavi@nutanix.com PASSWD=secret mount -t cifs //hpoc-afs/se /mnt/se/
  - mac: sudo mount -v -r -t nfs -o resvport,nobrowse,nosuid,locallocks,nfc,actimeo=1 10.21.34.37:/SelfServiceContainer/ nfstest
- mount AFS and then put a web/S/FTP server on top
- python -m SimpleHTTPServer 8080 || python -m http.server 8080

# Git Notes #

https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project

```
$ git remote show
origin

# https://gitversion.readthedocs.io/en/stable/reference/git-setup/
$ git remote add upstream https://github.com/nutanixworkshops/stageworkshop.git

$ git remote show
upstream
origin

$ git fetch upstream
$ git merge upstream/master

$ git tags
$ git tag -a 2.0.1 [hash]
$ git push origin --tags
````
