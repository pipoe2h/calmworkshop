.. _ansible_lamp_playbook:

----------------------
Ansible: LAMP Playbook
----------------------

Run Ansible Playbook to Deploy LAMP stack
+++++++++++++++++++++++++++++++++++++++++

.. note::

  These playbooks require Ansible 1.2 or greater

These playbooks are meant to be a reference and starter's guide to building
Ansible Playbooks. These playbooks were tested on CentOS 7.x so we recommend
that you use CentOS Server v7 to test these modules.

Download the playbook.tar (see link below) and copy it to directory /etc/ansible/ on the server hosting Ansible.

:download:`playbooks.tar <lamp_example.tar.gz>`

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
