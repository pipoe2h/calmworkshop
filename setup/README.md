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
5. [Authentication: Domain Controller](#authentication-domain-controller)
    1. [Tips](#tips)
    2. [Next Gen AutoDC](#next-gen-autodc)

## Available Workshops ##

1. Calm Introduction Workshop (AOS/AHV 5.5+)
2. Citrix Desktop on AHV Workshop (AOS/AHV 5.6)

## HPoC Cluster Reservation ##

Make your new reservation on https://rx.corp.nutanix.com/ with:

- __Region:__ NX-US-West region only
- __AOS + Hypevisor:__ proper versions for your workshop, specified above
  - Older or newer versions may not function as expected
- __OS Images:__ *do not* specify additional images (CentOS, Windows2012, etc.) to your reservation

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

## Authentication: Domain Controller ##

OpenLDAP works fine for authentication, but Prism Central has a problem with anything more than simple RBAC with it. https://jira.nutanix.com/browse/ENG-126217 will be fixed with PC 5.6.1

AutoDC was created by @John.Walker, using Turnkey Linux, to stand up a pre-configured Samba DC.
The console runs an ncurses application which allows simple reconfiguration of domain,
administator password, and reboots. Console credentials are root:nutanix/4u

> The auto_dc qcow2 that Johnny “Blue Label” Walker has created can be found here: http://10.21.250.221/images/auto_dc.qcow2
> It creates with four groups and corresponding users. basic-users, power-users, developers, and ssp-admins. (so, good to go from that perspective for PC/SSP/Calm). It sets up DNS forwarding correctly for the HPOC environment so anything it can’t resolve will forward to 10.21.250.10 / 10.21.250.11 -- meaning that you’re safe to create an IPAM network that uses that as its DNS server to resolve both hostnames you’ve created as well as nutanixdc.local and everything else outside. And it creates the domain ... poclab? IIRC?

> It is a Linux AD server (hence why it’s only 634MB instead of 40+GB) but can be managed by Windows tools so if you need further customization and want to do that in your familiar GUI you can still deploy a Win2012 image and manage it that way.
> There’s a deploy/reconfigure script that I’ll let @john.walker explain further.

> The short version is: Deploy a VM using the image and 2vCPU, 4GB RAM on a DHCP enabled VLAN.
> Once booted the console will show the domain settings and IP address,
 Domain settings can be changed in the advanced settings menu in the console if you want it to re-initialize with a different domain.

Users and groups are imported as part of the initialization:

|Username(s)|Password|Group|
|----|-----|-----|
|adminuser01-05|nutanix/4u|SSP Admins|
|devuser01-05|nutanix/4u|SSP Developers|
|poweruser01-05|nutanix/4u|SSP Power Users|
|basicuser01-05|nutanix/4u|SSP Basic Users|

### Tips ###

When rebuilding a HPOC from rx, foundation automation takes:
- 4 nodes@NX-3060-G5: 30 minutes
- 4 nodes@NX-1050: 40 minutes.

I believe you can [easily get away with 2GB RAM for AutoDC](https://github.com/mlavi/stageworkshop/blob/master/scripts/stage_calmhow.sh#L131),
 so I use that.

You may wish to use ````poc_samba_user.sh```` to populate AutoDC past the initial set of users, above:

1. Modify the hard-coded variables at the top if needed.
2. $ ````export DC_IP='10.21.example.40' && scp poc*sh root@${DC_IP}: && ssh root@${DC_IP} "chmod u+x poc*sh; ./poc_samba_users.sh"````

### Next Gen AutoDC ###

@JohnWalker: The new one I have built has an image size of 85MB and is based on Alpine linux.
I just need to finish the TUI interface for changing the config.
https://gitlab.com/devnull-42/alpine-dc

Mark: "Is there a web GUI type tool that we could build in? I’m thinking CPanel might be able to tackle that?"

@JohnWalker: I'm building a console interface in Python that will handle that.
I’m going to have a couple of ways. 1 would be to edit the users.csv and groups.csv.  The other would be to add users and groups individually without re-initializing the dc.
