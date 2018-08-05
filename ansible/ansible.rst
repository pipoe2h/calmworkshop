***************
Ansible
***************




Connectivity Instructions:
**************************

+------------+--------------------------------------------------------+
| IP         |                                           Cluster IP   |
+------------+--------------------------------------------------------+
| Username   |                                           Cluster User |
+------------+--------------------------------------------------------+
| Password   |                                           Cluster Pass |
+------------+--------------------------------------------------------+

Lab Overview
************

In this lab participants will install, configure, and deploy the Ansible orchestration software stack on CentOS Server v7 VM.  Once Ansible is stable, learners will develop and execute playbooks to deploy a LAMP stack and compare & contrast the differences with NuCalm.  We'll also explore developing running a simple Ansible module to standup infrastructure (i.e. VM creation).

Introduction
************

Configuration management systems are designed to make controlling large numbers of servers easy for administrators and operations teams. They allow you to control many different systems in an automated way from one central location. While there are many popular configuration management systems available for Linux systems, such as Chef and Puppet, these are often more complex than many people want or need. Ansible is a great alternative to these options because it has a much smaller overhead to get started.

Ansible works by configuring client machines from an computer with Ansible components installed and configured. It communicates over normal SSH channels in order to retrieve information from remote machines, issue commands, and copy files. Because of this, an Ansible system does not require any additional software to be installed on the client computers. This is one way that Ansible simplifies the administration of servers. Any server that has an SSH port exposed can be brought under Ansible's configuration umbrella, regardless of what stage it is at in its life cycle.

Ansible takes on a modular approach, making it easy to extend to use the functionalities of the main system to deal with specific scenarios. Modules can be written in any language and communicate in standard JSON. Configuration files are mainly written in the YAML data serialization format due to its expressive nature and its similarity to popular markup languages. Ansible can interact with clients through either command line tools or through its configuration scripts called Playbooks.

In this lab, you'll install Ansible on a CentOS 7 server and learn some basics of how to use the software.

Step 1 - Environment Setup
**************************

To follow this tutorial, you will need:

- Deploy 2x CentOS v7 Servers (One will be used for Web server & One for DB server).  Name the VM's: *WebServer* and *DBServer* respectively.
- Deploy 1x CentOS v7 VM to host Ansible. Name the VM *Ansible*.  Follow the steps in configure-centos-server-v7_ to create a non-root user.
- Make sure you can connect to the servers using a password-less_ connection/session.

Step 2 — Installing Ansible
***************************

To begin exploring Ansible as a means of managing our various servers, we need to install the Ansible software on at least one machine.  In this lab we'll install ansible using *yum*, but to be fare to the learner, the Ansible stack can also be installed using *git* or *pip*.

To get Ansible for CentOS 7, first ensure that the CentOS 7 EPEL repository is installed:

.. code-block:: bash

  $ sudo yum install epel-release

Once the repository is installed, install Ansible with yum:

.. code-block:: bash

  $ sudo yum install ansible


Step 3 — Configuring Ansible Hosts
**********************************

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

.. note:: Other text editors other than "vi" can be used as needed (i.e. nano, emacs, etc...).  Caution: They may need to be installed.

Add this code to the file:

.. code-block:: bash

  ---
  ansible_ssh_user: ansible

YAML files start with "---", so make sure you don't forget that part.

Save and close this file when you are finished. Now Ansible will always use the sammy user for the servers group, regardless of the current user.

If you want to specify configuration details for every server, regardless of group association, you can put those details in a file at /etc/ansible/group_vars/all. Individual hosts can be configured by creating files under a directory at /etc/ansible/host_vars.

Step 4 — Using Simple Ansible Commands
**************************************

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

Step 5 - Preparing The System for Development - Installing Python
*****************************************************************

Installation of Python on CentOS consists of a few (simple) stages, starting with updating the system, followed by getting any desired version of Python, and proceeding with the set up process.


Remember: You can see all available releases of Python by checking out the Releases page. Using the instructions here, you should be able to install any or all of them.

.. note:: This guide should be valid for CentOS version 7 as well as 6.x and 5.x.

Updating The Default CentOS Applications
========================================

Before we begin with the installation, let's make sure to update the default system applications to have the latest versions available.

Run the following command to update the system applications:

.. code-block:: bash

  $ sudo yum -y update

Preparing The System for Development Installations
==================================================

CentOS distributions are lean - perhaps, a little too lean - meaning they do not come with many of the popular applications and tools that you are likely to need.

This is an intentional design choice. For our installations, however, we are going to need some libraries and tools (i.e. development [related] tools) not shipped by default. Therefore, we need to get them downloaded and installed before we continue.

There are two ways of getting the development tools on your system using the package manager yum:

**Option #1 (not recommended):** Consists of downloading these tools (e.g. make, gcc etc.) one-by-one. It is followed by trying to develop something and highly-likely running into errors midway through - because you will have forgotten another package so you will switch back to downloading.

The recommended and sane way of doing this is following **Option #2:** Simply downloading a bunch of tools using a single command with yum software groups.

**YUM Software Groups**

YUM Software Groups consist of bunch of commonly used tools (applications) bundled together, ready for download all at the same time via execution of a single command and stating a group name. Using YUM, you can even download multiple groups together.

The group in question for us is the Development Tools.

How to Install Development Tools using YUM on CentOS
====================================================

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


Step 6 - Run Ansible Playbook to Deploy LAMP stack
**************************************************

**These playbooks require Ansible 1.2 or greater**

These playbooks are meant to be a reference and starter's guide to building
Ansible Playbooks. These playbooks were tested on CentOS 7.x so we recommend
that you use CentOS Server v7 to test these modules.

Download the playbook.tar (see link below) and copy it to directory /etc/ansible/ on the server hosting Ansible.

:download:`playbooks.tar <lab6/calm_workshop_lab6_lamp_example.tar.gz>`

Extract the archive as follows:

.. code-block:: bash

  $ tar -xzvf calm_workshop_lab6_lamp_example.tar.gz

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

.. note:: Replace http://ntnxwebhost/index.php with the ip-address of your webserver vm.  e.g.  if your websever ip-address is 10.21.68.92 you would use http://10.21.68.92/index.php

If successfull, your browser should connect to the new webserver and display the following message:

.. code-block:: bash

   Homepage_
   Hello, World! I am a web server configured using Ansible and I am : CentOS.localdomain
   List of Databases:
   information_schema foodb mysql performance_schema test

Click on the hyperlink Homepage_ displayed in the browser. The browser should display the following message:

.. code-block:: bash

   Hello Calm Workshop! My App deployed via Ansible...

Summary:
*********

Congratulations!  You're now ready to be a DevOps Engineer!!

.. _Homepage:
.. _configure-centos-server-v7: lab6/calm_workshop_lab6_config_centos.html
.. _password-less: lab6/calm_workshop_lab6_nopass.html
.. _Building-DockerImages-Automatically-With-Jenkins-Pipeline: https://blog.nimbleci.com/2016/08/31/how-to-build-docker-images-automatically-with-jenkins-pipeline/
