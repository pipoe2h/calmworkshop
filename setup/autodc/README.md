# AutoDC #

AutoDC (Auto Domain Controller) was created by @John.Walker, using Alpine (and Turnkey Linux?), to stand up a pre-configured Samba DC.

https://gitlab.com/devnull-42/alpine-dc

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
2. ````export DC_IP='10.21.example.40' && scp poc*sh root@${DC_IP}: && ssh root@${DC_IP} "chmod u+x poc*sh; ./poc_samba_users.sh"````

## Next Gen AutoDC ##

@JohnWalker: The new one I have built has an image size of 85MB and is based on Alpine linux.
I just need to finish the TUI interface for changing the config.

Mark: "Is there a web GUI type tool that we could build in? I’m thinking CPanel might be able to tackle that?"

@JohnWalker: I'm building a console interface in Python that will handle that.
I’m going to have a couple of ways. 1 would be to edit the users.csv and groups.csv.  The other would be to add users and groups individually without re-initializing the dc.

## Version2 ##

PC 5.9.x Authentication was changed to add optional search recursion and strengthen security. This regressed the behavior of authentication configuration that worked in PC 5.8.x and works in PE 5.9.x.

- https://jira.nutanix.com/browse/ENG-180716 "Invalid service account details" error message is incorrect

Workaround: autodc-2.0.qcow2 release.

John Walker [14:13]
I figured it out. The default certs are fine
Need to add the following to the [global] section in /etc/samba/smb.conf
  ldap server require strong auth = no
The connection from Prism wasn't strong enough so Samba was rejecting it.
I added that, restarted samba and was able to connect.
Using ldap://ip:389 and the DOMAIN\username format for the user
