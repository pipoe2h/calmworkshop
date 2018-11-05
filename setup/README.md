This script supports staging HPoC clusters for [Nutanix Workshops](http://www.nutanixworkshops.com).
It automates the majority of the [Workshop Setup Guide](http://www.nutanixworkshops.com/en/latest/setup/).
After HPoC Foundation, you can have push-button Calm in about half an hour!

# Table of Contents #

1. [Available Workshops](#available-workshops)
2. [HPoC Cluster Reservation](#hpoc-cluster-reservation)
3. [Staging Your HPoC](#staging-your-hpoc)
    1. [Interactive Usage](#interactive-usage)
    2. [Non-interactive Usage](#non-interactive-usage)
4. [Validate Staged Clusters](#validate-staged-clusters)
5. [Authentication](#authentication)

## Available Workshops ##

1. Calm Introduction Workshop (AOS/AHV 5.5+)
2. Citrix Desktop on AHV Workshop (AOS/AHV 5.6)

## HPoC Cluster Reservation ##

Make your new reservation on https://rx.corp.nutanix.com/ with:

- __Region:__ NX-US-West or US-East regions only
- __AOS + Hypevisor:__ proper versions for your workshop, specified above
  - Recommended: AOS and AHV 5.8
  - Older or newer versions may not function as expected
- __OS Images:__ *you do not* need to specify images (CentOS, Windows2012, etc.) for your reservation

## Staging Your HPoC ##

All clusters must be Foundationed prior to Workshop staging.

This script should be run from a host on the corporate/lab network,
 such as a CentOS VM running on an HPoC cluster or your laptop with VPN access.
Execute the following:

    git clone https://github.com/nutanixworkshops/stageworkshop.git
    cd stageworkshop
    chmod +x stage_workshop.sh

Next, you'll need to create or reuse and update a text file (*e.g.:* example_pocs.txt)
 containing your cluster IP and password details.
 It's easiest to create this file in the same directory as the stage_workshop.sh script.
 Input files must use the following format:

    <Nutanix Cluster #1 IP>|<Cluster #1 Password>|first.lasty@nutanix.com
    <Nutanix Cluster #2 IP>|<Cluster #2 Password>|example@nutanix.com
    ...
    <Nutanix Cluster #N IP>|<Cluster #N Password>|example@nutanix.com

For example:

    10.21.1.37|nx2Tech123!|you@nutanix.com
    10.21.7.37|nx2Tech517!|me@nutanix.com
    #10.21.5.37|nx2Tech789!|first.last@nutanix.com <-- The script will ignore commented out clusters
    10.21.55.37|nx2Tech456!|se@nutanix.com

Finally, execute the script to stage the HPOC clusters defined in your text file.

### Interactive Usage ###

````./stage_workshop.sh````

Running the script interactively
 will prompt you to input the name of your text file containing your cluster IP and password details.
 You will then be prompted to choose a Workshop to stage.

### Non-interactive Usage ###

````./stage_workshop.sh -f [example_pocs.txt] -w [workshop number]````

Each staging option will deploy:

- all images required to complete a given workshop
- a domain controller (ntnxlab.local)
- Prism Central
- configuring AHV networks for your Primary and Secondary VLANs.

If you encounter issues reach out to @matt on Slack.

## Validate Staged Clusters ##

After staging (~30m), you can re-run the stage_workshop script and select "Validate Staged Clusters" to perform a quick check to ensure all images were uploaded and that Prism Central was provisioned as expected.

Example:

````
./stage_workshop.sh
Cluster Input File: example_pocs.txt
1) Calm Introduction Workshop (AOS/AHV 5.6)
2) Citrix Desktop on AHV Workshop (AOS/AHV 5.6)
3) Change Cluster Input File
4) Validate Staged Clusters
5) Quit
Select an option: 4
10.21.44.37 - Prism Central staging FAILED
10.21.44.37 - Review logs at 10.21.44.37:/home/nutanix/config.log and 10.21.44.39:/home/nutanix/pcconfig.log
````

## Authentication ##

OpenLDAP works fine for authentication, but Prism Central has a problem with anything more than simple RBAC with it.
- https://jira.nutanix.com/browse/ENG-126217 openldap authentication difference in PC vs PE
  - fixed with PC 5.7.1

In the meantime, one can use Windows Server: Active Directory, but for simpler and faster results, the automation leverages [AutoDC](autodc/README.md).
