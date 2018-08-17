.. _ansible_basics:

---------------
Ansible: Basics
---------------

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
