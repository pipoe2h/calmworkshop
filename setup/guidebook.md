# HPoC Automation: Push Button Calm

## Caveat ##

This is a work in progress and your milage may vary!

## Prerequisites ##

1. Tested on Ubuntu and Mac (Mac requires https://brew.sh installed).
2. A terminal with command line git.

### Acknowledgements ###

The entire Global Technical Sales Enablement team has delivered an amazing
 amount of content and automation for Nutanix TechSummits and Workshops. Along with the Corporate SE team automation gurus, it has been a pleasure to work with all of them and this work stands on the shoulder of those giants.
 Thank you!

### For the Impatient ###

    echo "Start Foundation on your HPoC now, we'll wait 40 minutes..."

    export PE=10.21.X.37 && export PE_PASSWORD='nx2Tech###!' && EMAIL=first.last@nutanix.com \
    && cd $(git clone https://github.com/mlavi/stageworkshop.git 2>&1 | grep Cloning | awk -F\' '{print $2}') \
    && echo "${PE}|${PE_PASSWORD}|${EMAIL}" > clusters.txt \
    && ./stage_workshop.sh -f clusters.txt -w 1 #latest calm

    sleep 60*30 && lynx https://admin:${PE_PASSWORD}@${PE}:9440/

While Foundation typically takes ~30 minutes, we'll:

1. Set the Prism Element (PE) IP address, password, and your email address,
2. Change directory into the cloned git repository,
3. Put settings into a configuration file,
4. Stage the cluster with the configuration file and the latest Calm workshop.

Approximately 30 minutes later, you can login to PE to get to PC and follow step #7 below to finish push button Calm automation.

## Bugs, Priorities, Notes ##

See [the planning and working document](bugs.md).

### Timing ###

We'll round up to the nearest half minute.

1. 30 min = RX Foundation times to PE up (approximate)

| Cluster | 5/24 (minutes) | 6/2 (min) | 6/10 (min) |
| :------------- | ------------- | --- | ---------- |
| NX-1060 | 30 | N/A | N/A |
| NX-3060-G5 | 25 | 35 | 33 |

2. 0.5 min per cluster = ./stage_workshop.sh

3. 28/26/20 min = PE:stage_calmhow.sh
Typical download and install of Prism Central is 17 minutes of waiting!

| Function | Run1@5/24 (minutes) | 6/2 (min) | 6/10 (min) |
| :------------- | :------------- | --- | ---------- |
| __start__ | 11:26:53 | 09:07:55 | 03:15:35 |
| __end__ | 11:54:28 | 09:34:09 | 03:35:25 |

4. 1.5 min = PC:stage_calmhow_pc.sh

| Function | Run1@5/24 (minutes) | 6/2 (min) | 6/10 (min) |
| :------------- | :------------- | --- | ---------- |
| __start (localtime)__ | 04:54:27 | 02:34:08 | 20:35:24 |
| __end (localtime)__ | 04:55:57 | 02:35:37 | 20:36:45 |

5. 2 min: Login to PC, manual configuration of Calm default project (see step 7, below).

## Procedure ##

0. Crank some tunes and record the start time!
1. __Browse (tab1)__ to this page = https://github.com/mlavi/stageworkshop/blob/master/guidebook.md

    - I have submitted [a pull request](https://github.com/nutanixworkshops/stageworkshop/pull/1) to merge my work.
2. __Browse (tab2)__ to review HPoC reservation details in https://rx.corp.nutanix.com:8443/

    1. Find the __Cluster External IP__ and the __PE admin password__:
    we will use both of these in a moment.
    2. Memorize the HPOC number (third octet of the External IPv4)
    and prepare to copy by highlighting the __PE admin password__
    or merely memorize the three digits of __PE admin password__.
    3. *Browse (tab3)* to the PE URL to show unavailable before or during foundation process.
    4. *Launch a new terminal*:

        1. Change terminal font size for demo.
        2. Cut and paste the first line the follows to create, and change to the repository directory
            - or cut and paste the entire code block if you're comfortable editing the command line,
            - otherwise copy one line at a time and substitute __Cluster External IP__
            on the ````MY_HPOC```` assignment line or change that ````X```` you cleverly memorized
            and paste the __PE admin password__ onto the ````MY_PE_PASSWORD```` line
            or change the ````###```` you cleverly memorized.

        git clone https://github.com/mlavi/stageworkshop.git && cd $_
        export MY_HPOC=10.21.X.37 \
        && export MY_PE_PASSWORD='nx2Tech###!' \
        && echo "${MY_HPOC}|${MY_PE_PASSWORD}" >> example_pocs.txt

        - *OPTIONAL:* Make a mistake with the HPoC octet to show a failure mode.
        - That's it, you're done! Just sit back and wait, periodically
        reload browser tab3, or follow the log output on PE and PC...

1. Side by side: (screens because split desktop doesn't work well enough)

   1. __Browser (tab 2):__ Open RX automation cluster foundation status detail page, it will be tab4.
   2. __Terminal:__ After the automation is uploaded to the cluster CVM, copy and paste the command to monitor the ````stage_calmhow.sh```` progress.

   3. __Browser (tab3):__ Reload the PE URL, accept security override, login as admin and password to PE EULA.
   4. __Terminal:__ Once PE UI configured, reload browser tab3 to show EULA bypassed or click on the decline EULA button to return to login prompt.

      - *BUG:* Once Authentication Server is up, you should be able to login as a SSP admin = adminuser05@ntnxlab.local
  5. __Browser:__

      - Show PE Authentication: test above user with the default password.
      - View All Tasks, wait until software is uploading
  6. __Terminal:__ Show that we're waiting...approximately 17 minutes (fast forward). Highlight automation scripts sent to PC.
  7. __Browser:__ from PE, show VM table, go to home and show PE registered to PC, launch PC and login as admin.

    * *BUG:* Can't login as a SSP admin = adminuser05@ntnxlab.local
    * Show Authentication, show role mapping, show images.

1. Push button Calm!

    1. __PC> Apps:__ click lower left ? to show Calm 5.7

        * *BUG* why a ? in the UI?
    2. __Projects:__ Default: add the following:

      - Description: "Freedom to Cloud",
      - Roles: assign and save,
      - Local and Cloud,
      - choose PoC AHV cluster,
      - Network: enable VLANs,
      - and Save.
    3. __Blueprints:__ Upload blueprint: ````beachhead-centos7-calm5.7.0.1.json```` in default project.

      - Resize icon
      - Pull left tab open, note public key in AHVCluster application profile, zoom to show end of the value.
      - __Credentials:__ upload private key, note user centos, save, back.
      - __Service = Webtier:__

          - Show VM name, zoom in to show macros.
          - Choose local image uploaded to cluster to save time versus the dynamic imported image.
          - Show user centos in cloud-init and @@{your_public_key}@@ macro.
          - Show package install task: uncomment install work
          - Show service tab: Deployment Config

            - *bug* service > service is redundant!
        - Save, Launch!
    4. __Application Launch:__

      - Name application deployment: marklavi-beachhead-took-X-minutes
      - Terminal: find start time, find end time.

        - *BUG:* time zones of server, cloud-init?

      - Show logical deployment, open terminal, audit logs
