===================================================================
Building & Deploying LAMP stack Application using Ansible Playbooks
===================================================================

**These playbooks require Ansible 1.2 or greater**

These playbooks are meant to be a reference and starter's guide to building
Ansible Playbooks. These playbooks were tested on CentOS 7.x so we recommend
that you use CentOS Server v7 to test these modules.

Clone this playbook repository to /etc/ansible/ on the server hosting Ansible. 

CentOS v7 reflects changes in:

1. Network device naming scheme has changed

2. iptables is replaced with firewalld

3. MySQL is replaced with MariaDB

This LAMP stack can be on a single node or multiple nodes. The inventory file
'hosts' defines the nodes in which the stacks should be configured.

.. code-block:: bash

  [webservers]
   ntnxwebhost

  [dbservers]
   ntnxdbhost

Here the webserver would be configured on the ntnxweb host and the dbserver on a
server called ntnxdbhost. The stack can be deployed using the following
command:

.. code-block:: bash

  $ ansible-playbook -i hosts site.yml

Once done, you can check the results by browsing to http://ntnxwebhost/index.php.
You should see a simple test page and a list of databases retrieved from the
database server.
