.. _lab_ansible:
-------------
Lab - Ansible
-------------

Overview
++++++++

In this lab participants will install, configure, and deploy the Ansible orchestration software stack on CentOS Server v7 VM.  Once Ansible is stable, learners will develop and execute playbooks to deploy a LAMP stack and compare & contrast the differences with NuCalm.  We'll also explore developing running a simple Ansible module to standup infrastructure (i.e. VM creation).

Introduction
++++++++++++

Configuration management systems are designed to make controlling large numbers of servers easy for administrators and operations teams. They allow you to control many different systems in an automated way from one central location. While there are many popular configuration management systems available for Linux systems, such as Chef and Puppet, these are often more complex than many people want or need. Ansible is a great alternative to these options because it has a much smaller overhead to get started.

Ansible works by configuring client machines from an computer with Ansible components installed and configured. It communicates over normal SSH channels in order to retrieve information from remote machines, issue commands, and copy files. Because of this, an Ansible system does not require any additional software to be installed on the client computers. This is one way that Ansible simplifies the administration of servers. Any server that has an SSH port exposed can be brought under Ansible's configuration umbrella, regardless of what stage it is at in its life cycle.

Ansible takes on a modular approach, making it easy to extend to use the functionalities of the main system to deal with specific scenarios. Modules can be written in any language and communicate in standard JSON. Configuration files are mainly written in the YAML data serialization format due to its expressive nature and its similarity to popular markup languages. Ansible can interact with clients through either command line tools or through its configuration scripts called Playbooks.

In this lab, you'll install Ansible on a CentOS 7 server and learn some basics of how to use the software.

Create Three VMs
++++++++++++++++

.. note::

  Skip this VM creation section if you have already created the VMs.

Now you will create the **three** virtual machines you will use to test the capabilities of Ansible. Create these virtual machines from the base VM in Prism Central called CentOS.

In **Prism Central > Explore > VMs**, click **Create VM**.

Fill out the following fields and click **Save**:

- **Name** - ansible-<your_initials>-1
- **Description** - Ansible testing VM
- **vCPU(s)** - 2
- **Number of Cores per vCPU** - 1
- **Memory** - 4 GiB
- Select **+ Add New Disk**

  - **Operation** - Clone from Image Service
  - **Image** - CentOS
  - Select **Add**
- Remove **CD-ROM** Disk
- Select **Add New NIC**

  - **VLAN Name** - Primary
  - Select **Add**

Clone the other two VMs:
........................

Take that VM and clone it two times to have a total of three VMs named as follows:

ansible-<your_initials>-1 (Ansible Server)
ansible-<your_initials>-2 (Web Server)
ansible-<your_initials>-3 (DB Server)

Select the **ansible-<your_initials>-1** VM and click **Actions > Clone**.

- **Number of Clones** - 2
- **Prefix Name** - ansible-<your_initials>-
- **Starting Index Number** - 2

Select the three newly created Ansible VMs and click **Actions > Power on**.

Setup CentOS Servers
++++++++++++++++++++

When you first create a new server, there are a few configuration steps that you should take early on as part of the basic setup. This will increase the security and usability of your server and will give you a solid foundation for subsequent actions.

Root Login
..........

Log into your server, you will need to know your server's public IP address and the password for the "root" user's account.

.. code-block:: bash

  $ ssh root@SERVER_IP_ADDRESS

Complete the login process by accepting the warning about host authenticity, if it appears, then providing your root authentication (password or private key). If it is your first time logging into the server, with a password, you may also be prompted to change the root password.

Create a New User
.................

Once you are logged in as root, we're prepared to add the new user account that we will use to log in from now on.

.. code-block:: bash

  $ adduser calm

Next, assign a password to the new user:

.. code-block:: bash

  $ passwd calm

Enter a password, and repeat it again to verify it.

Assign Root Privileges
......................

Now, we have a new user account with regular account privileges. However, we may sometimes need to do administrative tasks. To avoid having to log out of our normal user and log back in as the root account, we can set up what is known as "super user" or root privileges for our normal account. This will allow our normal user to run commands with administrative privileges by putting the word sudo before each command.
To add these privileges to our new user, we need to add the new user to the "wheel" group. By default, on CentOS 7, users who belong to the "wheel" group are allowed to use the sudo command.
As root, run this command to add your new user to the wheel group:

.. code-block:: bash

  $ gpasswd -a calm wheel

Now your user can run commands with super user privileges! For more information about how this works, check out our sudoers tutorial.

(Optional) — Configure SSH Daemon
.................................

Now that we have our new account, we can secure our server a little bit by modifying its SSH daemon configuration (the program that allows us to log in remotely) to disallow remote SSH access to the root account.

Begin by opening the configuration file with your text editor as root:

.. code-block:: bash

  $ vi /etc/ssh/sshd_config

Here, we have the option to disable root login through SSH. This is generally a more secure setting since we can now access our server through our normal user account and escalate privileges when necessary.

To disable remote root logins, we need to find the line that looks like this:

/etc/ssh/sshd_config (before)

.. code-block:: bash

  #PermitRootLogin yes

Hint: To search for this line, type /PermitRoot then hit ENTER. This should bring the cursor to the "P" character on that line.

Uncomment the line by deleting the "#" symbol (press Shift-x).

Now move the cursor to the "yes" by pressing c.

Now replace "yes" by pressing cw, then typing in "no". Hit Escape when you are done editing. It should look like this:

.. code-block:: bash

  /etc/ssh/sshd_config (after)
  PermitRootLogin no

Disabling remote root login is highly recommended on every server!

Enter :x then ENTER to save and exit the file.

**Reload SSH**

Now that we have made our changes, we need to restart the SSH service so that it will use our new configuration.

Type this to restart SSH:

.. code-block:: bash

  $ systemctl reload sshd

Now, before we log out of the server, we should test our new configuration. We do not want to disconnect until we can confirm that new connections can be established successfully.

Open a new terminal window. In the new window, we need to begin a new connection to our server. This time, instead of using the root account, we want to use the new account that we created.

For the server that we configured above, connect using this command. Substitute your own information where it is appropriate:

.. code-block:: bash

  $ ssh calm@SERVER_IP_ADDRESS

**Note:** If you are using PuTTY to connect to your servers, be sure to update the session's port number to match your server's current configuration.

You will be prompted for the new user's password that you configured. After that, you will be logged in as your new user.

Remember, if you need to run a command with root privileges, type "sudo" before it like this:

.. code-block:: bash

  $ sudo command_to_run

If all is well, you can exit your sessions by typing:

.. code-block:: bash

  $ exit

At this point, you have a solid foundation for your server. You can install any of the software you need on your server now.

SSH Password-less Login
+++++++++++++++++++++++

SSH is a client and server protocol, and it helps us to access the remote system over the network through the encrypted tunnel. Whenever the client access the server, the client downloads the secure key from the server and at the same time-server also downloads the key from a client. Those two keys make the encrypted tunnel between the server and client, so that data transfer very securely over the network.
SSH is widely used as the alternative to FTP, as you know any thing that uses TCP network asks password to collect data. SSH is also a TCP service, and it requires a password to access the remote machine. If the organization has a large number of servers, every time admin has to enter the password to access the remote system. It is a pain to enter the password multiple times; SSH comes with new feature called password less login, that helps to access the remote machine without entering the password.
To enable the password less login, we have to put the public key entry of client host name and user detail on the remote server. That key entry will be on the following file (~/.ssh/authorized_keys) (~=Home directory of the user) according to your remote user.
Follow the steps to create the password less login. Here we have two machines with two different usernames

Create remote users
...................

Create/Add a new user *ansible*, on each of the CentOS servers used for *Web* (ansible-<your_initials>-2) and *DB* (ansible-<your_initials>-3).

.. code-block:: bash

  $ adduser ansible
  $ passwd ansible
  Changing password for user test.
  New password:   (type: P@$$w0rd)
  Retype new password: (type: P@$$w0rd)
  passwd: all authentication tokens updated successfully
  $

Create SSH KEY
**************

- Login to CentOS Server hosting *Ansible* (ansible-<your_initials>-1) as user: *calm*.
- Create a pair of keys using the *ssh-keygen* command:

.. code-block:: bash

  $ ssh-keygen
  Generating public/private rsa key pair.
  Enter file in which to save the key (/home/nucalm/.ssh/id_rsa):      **Press Enter**
  Created directory '/home/test/.ssh'.
  Enter passphrase (empty for no passphrase):                          **Press Enter**
  Enter same passphrase again:                                         **Press Enter**
  Your identification has been saved in /home/test/.ssh/id_rsa.
  Your public key has been saved in /home/test/.ssh/id_rsa.pub.
  The key fingerprint is:
  f0:00:a0:12:6f:27:1b:2e:38:a2:4b:37:d8:65:5c:36 test@CentOS.localdomain
  The key's randomart image is:
  +--[ RSA 2048]----+
  |. ...            |
  | +   .           |
  |o = . oE         |
  |oo =. o+.        |
  |= o  +  S        |
  |ooo o            |
  |.o +             |
  |... .            |
  |.                |
  +-----------------+

  $

Migrate SSH KEY
...............

Once you have successfully created the keys, you will find two files inside you *.ssh* directory: *id_rsa* and *id_rsa.pub*. We are going to use *id_rsa.pub* as a base file.

.. code-block:: bash

  $ ll ~/.ssh/
  total 8
  -rw-------. 1 test test 1679 Dec 10 09:51 id_rsa
  -rw-r--r--. 1 test test  405 Dec 10 09:51 id_rsa.pub

Use the *ssh-copy-id* command with an input file of *id_rsa.pub*; it creates ~/.ssh/authorized_keys if not present, otherwise it would replace the key.

.. note::

  The key contains the information about *calm* host and user name.

Copy the new keys from the *Ansible* server to the *Web* and *DB* servers using the ansible user created earlier.

.. code-block:: bash

  $ ssh-copy-id -i ~/.ssh/id_rsa.pub ansible@remote-machine-ipaddress

and

.. code-block:: bash

  $ ssh-copy-id -i ~/.ssh/id_rsa.pub root@remote-machine-ipaddress

Test your password-less logins using *ssh* to login to each of the hosts.

.. code-block:: bash

  $ ssh ansible@[IP ADDRESS]
  Last login: Sun Dec 10 09:24:56 2017 from 10.21.9.85
  $

.. note:: You should **NOT** be prompted for a password...

Installing Ansible
++++++++++++++++++

To begin exploring Ansible as a means of managing our various servers, we need to install the Ansible software on at least one machine.  In this lab we'll install ansible using *yum*, but to be fare to the learner, the Ansible stack can also be installed using *git* or *pip*.

To get Ansible for CentOS 7, first ensure that the CentOS 7 EPEL repository is installed:

.. code-block:: bash

  $ sudo yum install epel-release

Once the repository is installed, install Ansible with yum:

.. code-block:: bash

  $ sudo yum install ansible


Configuring Ansible Hosts
+++++++++++++++++++++++++

Ansible keeps track of all of the servers that it knows about through a *"hosts"* file. We need to set up this file first before we can begin to communicate with our other computers.

Open the file with root privileges like this:

.. code-block:: bash

  $ sudo vi /etc/ansible/hosts

You will see a file that has a lot of example configurations commented out. Keep these examples in the file to help you learn Ansible's configuration if you want to implement more complex scenarios in the future.

The hosts file is fairly flexible and can be configured in a few different ways. The syntax we are going to use though looks something like this:

.. code-block:: bash

  [group_name]
  alias ansible_ssh_host=your_server_ip


The *group_name* is an organizational tag that lets you refer to any servers listed under it with one word. The alias is just a name to refer to that server.

Imagine you have three servers you want to control with Ansible. Ansible communicates with client computers through SSH, so each server you want to manage should be accessible from the Ansible server by typing:

.. code-block:: bash

  $ ssh user@your_server_ip

You should **NOT** be prompted for a password. While Ansible certainly has the ability to handle password-based SSH authentication, SSH keys help keep things simple (see password-less_ configuration).

Let's set this up so that we can refer to these individually as host1 and host2, or as a group of servers. To configure this, you would add this block to your hosts file:

*/etc/ansible/hosts*

.. code-block:: bash

  [servers]
  host1 ansible_ssh_host=IP ADDRESS
  host2 ansible_ssh_host=IP ADDRESS


Hosts can be in multiple groups and groups can configure parameters for all of their members. Let's try this out now.

Ansible will, by default, try to connect to remote hosts using your current username. If that user doesn't exist on the remote system, a connection attempt will result in this error:

.. code-block:: bash

  Annsible connection error
  host1 | UNREACHABLE! => {
      "changed": false,
      "msg": "Failed to connect to the host ia ssh.",
      "unreachable": true
  }

Let's specifically tell Ansible that it should connect to servers in the "servers" group with the **ansible** user. Create a directory in the Ansible configuration structure called group_vars.

.. code-block:: bash

  $ sudo mkdir /etc/ansible/group_vars

Within this folder, we can create YAML-formatted files for each group we want to configure:

.. code-block:: bash

  $ sudo vi /etc/ansible/group_vars/servers

.. note::

  Other text editors other than "vi" can be used as needed (i.e. nano, emacs, etc...).  Caution: They may need to be installed.

Add this code to the file:

.. code-block:: bash

  ---
  ansible_ssh_user: ansible

YAML files start with "---", so make sure you don't forget that part.

Save and close this file when you are finished. Now Ansible will always use the sammy user for the servers group, regardless of the current user.

If you want to specify configuration details for every server, regardless of group association, you can put those details in a file at /etc/ansible/group_vars/all. Individual hosts can be configured by creating files under a directory at /etc/ansible/host_vars.

Using Simple Ansible Commands
+++++++++++++++++++++++++++++

Now that we have our hosts set up and enough configuration details to allow us to successfully connect to our hosts, we can try out our very first command.

Ping all of the servers you configured by typing:

.. code-block:: bash

  $ ansible -m ping all

Ansible will return output like this:

.. code-block:: bash

  Output
  host1 | SUCCESS => {
      "changed": false,
      "ping": "pong"
  }

  host2 | SUCCESS => {
      "changed": false,
      "ping": "pong"
  }

  host3 | SUCCESS => {
      "changed": false,
      "ping": "pong"
  }

This is a basic test to make sure that Ansible has a connection to all of its hosts.

The -m ping portion of the command is an instruction to Ansible to use the "ping" module. These are basically commands that you can run on your remote hosts. The ping module operates in many ways like the normal ping utility in Linux, but instead it checks for Ansible connectivity.

The all portion means "all hosts." You could just as easily specify a group:

.. code-block:: bash

  $ ansible -m ping servers

You can also specify an individual host:

.. code-block:: bash

  $ ansible -m ping host1

You can specify multiple hosts by separating them with colons:

.. code-block:: bash

  $ ansible -m ping host1:host2

The shell module lets us send a terminal command to the remote host and retrieve the results. For instance, to find out the memory usage on our host1 machine, we could use:

.. code-block:: bash

  $ ansible -m shell -a 'free -m' host1

As you can see, you pass arguments into a script by using the -a switch. Here's what the output might look like:

.. code-block:: bash

  Output
  host1 | SUCCESS | rc=0 >>
              total        used        free      shared  buff/cache   available
  Mem:         3765         295        1712          16        1757        3181
  Swap:        1023           0        1023



By now, you should have your Ansible server configured to communicate with the servers that you would like to control. You can verify that Ansible can communicate with each host you know how to use the ansible command to execute simple tasks remotely.

Although this is useful, we have not covered the most powerful feature of Ansible in this lab: **Playbooks.** You have configured a great foundation for working with your servers through Ansible, so your next step is to learn how to use Playbooks to do the heavy lifting for you.

Preparing The System for Development - Installing Python
++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Installation of Python on CentOS consists of a few (simple) stages, starting with updating the system, followed by getting any desired version of Python, and proceeding with the set up process.

Remember: You can see all available releases of Python by checking out the Releases page. Using the instructions here, you should be able to install any or all of them.

.. note::

  This guide should be valid for CentOS version 7 as well as 6.x and 5.x.

Updating The Default CentOS Applications
........................................

Before we begin with the installation, let's make sure to update the default system applications to have the latest versions available.

Run the following command to update the system applications:

.. code-block:: bash

  $ sudo yum -y update

Preparing The System for Development Installations
..................................................

CentOS distributions are lean - perhaps, a little too lean - meaning they do not come with many of the popular applications and tools that you are likely to need.

This is an intentional design choice. For our installations, however, we are going to need some libraries and tools (i.e. development [related] tools) not shipped by default. Therefore, we need to get them downloaded and installed before we continue.

There are two ways of getting the development tools on your system using the package manager yum:

**Option #1 (not recommended):** Consists of downloading these tools (e.g. make, gcc etc.) one-by-one. It is followed by trying to develop something and highly-likely running into errors midway through - because you will have forgotten another package so you will switch back to downloading.

The recommended and sane way of doing this is following **Option #2:** Simply downloading a bunch of tools using a single command with yum software groups.

**YUM Software Groups**

YUM Software Groups consist of bunch of commonly used tools (applications) bundled together, ready for download all at the same time via execution of a single command and stating a group name. Using YUM, you can even download multiple groups together.

The group in question for us is the Development Tools.

How to Install Development Tools using YUM on CentOS
....................................................

In order to get the necessary development tools, run the following:

.. code-block:: bash

  $ sudo yum groupinstall -y development

or;

.. code-block:: bash

  $ sudo yum groupinstall -y 'development tools'

.. note:: The former (shorter) version might not work on older distributions of CentOS.

To download some additional packages which are handy:

.. code-block:: bash

  $ sudo yum install -y zlib-dev openssl-devel sqlite-devel bzip2-devel

Remember: Albeit optional, these "handy" tools are very much required for most of the tasks that you will come across in future. Unless they are installed in advance, Python, during compilation, will not be able to link to them.


Run Ansible Playbook to Deploy LAMP stack
+++++++++++++++++++++++++++++++++++++++++

.. note::

  These playbooks require Ansible 1.2 or greater

These playbooks are meant to be a reference and starter's guide to building
Ansible Playbooks. These playbooks were tested on CentOS 7.x so we recommend
that you use CentOS Server v7 to test these modules.

Download the playbook.tar (see link below) and copy it to directory /etc/ansible/ on the server hosting Ansible.

:download:`playbooks.tar </lamp_example.tar.gz>`

Extract the archive as follows:

.. code-block:: bash

  $ tar -xzvf lamp_example.tar.gz

CentOS v7 reflects playbook changes in:

1. Network device naming scheme has changed

2. iptables is replaced with firewalld

3. MySQL is replaced with MariaDB

This LAMP stack can be on a single node or multiple nodes. The inventory file
'hosts' defines the nodes in which the stacks should be configured.

.. code-block:: bash

  [webservers]
   ntnxwebhost ansible_ssh_host=IP ADDRESS

  [dbservers]
   ntnxdbhost ansible_ssh_host=IP ADDRESS

Here the [webservers] would be configured on the ntnxweb host and the [dbservers] on a
server called ntnxdbhost. The stack can be deployed using the following
command:

.. code-block:: bash

  $ ansible-playbook -i hosts site.yml

Once done, you can check the results by browsing to http://ntnxwebhost/index.php.
You should see a simple test page and a list of databases retrieved from the
database server.

.. note::

  Replace http://ntnxwebhost/index.php with the ip-address of your webserver vm.  e.g.  if your websever ip-address is 10.21.68.92 you would use http://10.21.68.92/index.php

If successful, your browser should connect to the new webserver and display the following message:

.. code-block:: bash

   Homepage_
   Hello, World! I am a web server configured using Ansible and I am : CentOS.localdomain
   List of Databases:
   information_schema foodb mysql performance_schema test

Click on the hyperlink Homepage_ displayed in the browser. The browser should display the following message:

.. code-block:: bash

   Hello Calm Workshop! My App deployed via Ansible...

Summary:
++++++++

Congratulations!  You're now ready to be a DevOps Engineer!!
