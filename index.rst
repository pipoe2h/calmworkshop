.. title:: Nutanix Calm and Flow Bootcamp

.. toctree::
  :maxdepth: 2
  :caption: Technology Overview
  :name: _technology_overview
  :hidden:

  what_is_nutanix/what_is_nutanix
  nutanix_terminology/nutanix_terminology
  nutanix101/nutanix101


.. toctree::
  :maxdepth: 2
  :caption: Intro Calm Labs
  :name: _intro_calm_labs
  :hidden:

  what_is_calm/what_is_calm
  calm_basics/basics
  calm_enable/calm_enable
  calm_projects/calm_projects
  calm_marketplace/calm_marketplace

.. toctree::
  :maxdepth: 2
  :caption: Main Calm Labs
  :name: _main_calm_labs
  :hidden:

  calm_sshkey_creation/calm_sshkey_creation
  calm_singlevm_blueprint/calm_singlevm_blueprint
  calm_mysql_blueprint/calm_mysql_blueprint
  calm_linux/calm_linux
  calm_day2/calm_day2
  calm_windows_blueprint/calm_windows_blueprint
  calm_win/calm_win


.. toctree::
  :maxdepth: 2
  :caption: Advanced Labs
  :name: _advanced_labs
  :hidden:

  calm_escript/calm_escript
  calm_wordpress_blueprint/calm_wordpress_blueprint

.. toctree::
  :maxdepth: 2
  :caption: Flow Labs
  :name: _flow_labs
  :hidden:

  what_is_flow/what_is_flow
  flow_enable/flow_enable
  flow_quarantine_vm/flow_quarantine_vm
  flow_isolate_environments/flow_isolate_environments
  flow_secure_app/flow_secure_app
  flow_visualization/flow_visualization


.. toctree::
  :maxdepth: 2
  :caption: Appendix
  :name: _appendix
  :hidden:

  appendix/glossary

.. _getting_started:

-------------
Calm Bootcamp
-------------

Welcome to the Calm Bootcamp! This workbook accompanies an instructor-led session that introduces Nutanix Calm and many common management tasks. Each section has a lesson and an exercise to give you hands-on practice. The instructor explains the exercises and answers any additional questions that you may have.

At the end of the bootcamp, attendees should understand the basic concepts and technologies that make up Nutanix Calm and should be well prepared to install, design and operate Calm blueprints and applications.

What's New
++++++++++

- Bootcamp updated for the following software versions:
    - AOS|Prism Central 5.10


- Optional Labs:
    - Flow

Agenda
++++++

- Introductions
- Technology Overview
- Intro Nutanix Calm Labs
- Main Calm Labs
- Advanced Calm Labs
- Flow Labs

Introductions
+++++++++++++

- Name
- Familiarity with Nutanix
- Experiance with Calm
- Experiance with DevOps technologies
- Experiance with Flow

Initial Setup
+++++++++++++

- Take note of the *Passwords* being used.
.. note::
  - If this workshop is being run on the local infrastrcture you will **not** use the connection information below. Your instructor will communicate this information directly to you.
  - If this workshop is being hosted on the Nutanix POC environment please see the connection information below.

Nutanix Hosted Environment Details
+++++++++++++++++++

**Connection information here is only for classes that are hosted on the Nutanix POC environment.**
Nutanix Bootcamps are intended to be run in the Nutanix Hosted POC environment. Your cluster will be provisioned with all necessary images, networks, and VMs required to complete the exercises.

Networking
..........

Hosted POC clusters follow a standard naming convention:

- **Cluster Name** - POC\ *XYZ*
- **Subnet** - 10.**21**.\ *XYZ*\ .0
- **Cluster IP** - 10.**21**.\ *XYZ*\ .37

If provisioned from the marketing pool:

- **Cluster Name** - MKT\ *XYZ*
- **Subnet** - 10.**20**.\ *XYZ*\ .0
- **Cluster IP** - 10.**20**.\ *XYZ*\ .37

For example:

- **Cluster Name** - POC055
- **Subnet** - 10.21.55.0
- **Cluster IP** - 10.21.55.37

Throughout the Bootcamp there are multiple instances where you will need to substitute *XYZ* with the correct octet for your subnet, for example:

.. list-table::
  :widths: 25 75
  :header-rows: 1

  * - IP Address
    - Description
  * - 10.21.\ *XYZ*\ .37
    - Nutanix Cluster Virtual IP
  * - 10.21.\ *XYZ*\ .39
    - **PC** VM IP, Prism Central
  * - 10.21.\ *XYZ*\ .40
    - **DC** VM IP, NTNXLAB.local Domain Controller

Each cluster is configured with 2 VLANs which can be used for VMs:

.. list-table::
  :widths: 25 25 10 40
  :header-rows: 1

  * - Network Name
    - Address
    - VLAN
    - DHCP Scope
  * - Primary
    - 10.21.\ *XYZ*\ .1/25
    - 0
    - 10.21.\ *XYZ*\ .50-10.21.\ *XYZ*\ .124
  * - Secondary
    - 10.21.\ *XYZ*\ .129/25
    - *XYZ1*
    - 10.21.\ *XYZ*\ .132-10.21.\ *XYZ*\ .253

Credentials
...........

.. note::

  The *<Cluster Password>* is unique to each cluster and will be provided by the leader of the Bootcamp.

.. list-table::
  :widths: 25 35 40
  :header-rows: 1

  * - Credential
    - Username
    - Password
  * - Prism Element
    - admin
    - *<Cluster Password>*
  * - Prism Central
    - admin
    - *<Cluster Password>*
  * - Controller VM
    - nutanix
    - *<Cluster Password>*
  * - Prism Central VM
    - nutanix
    - *<Cluster Password>*

Each cluster has a dedicated domain controller VM, **DC**, responsible for providing AD services for the **NTNXLAB.local** domain. The domain is populated with the following Users and Groups:

.. list-table::
  :widths: 25 35 40
  :header-rows: 1

  * - Group
    - Username(s)
    - Password
  * - Administrators
    - Administrator
    - nutanix/4u
  * - SSP Admins
    - adminuser01-adminuser25
    - nutanix/4u
  * - SSP Developers
    - devuser01-devuser25
    - nutanix/4u
  * - SSP Power Users
    - poweruser01-poweruser25
    - nutanix/4u
  * - SSP Basic Users
    - basicuser01-basicuser25
    - nutanix/4u

Nutanix Hosted Access Instructions
++++++++++++++++++++++++++++++++++

The Nutanix Hosted POC environment can be accessed a number of different ways:

Parallels VDI
.................

1) Login to https://xld-uswest1.nutanix.com (for PHX) or https://xld-useast1.nutanix.com (for RTP) using your supplied credentials
2) Select HTML5 (web browser) OR Install the Parallels Client
3) Select a desktop or application of your choice.

**Nutanix Employees** - Use your NUTANIXDC credentials

PHX
---
**Non-Employees** - **Username:** PHX-POCxxx-User01 (up to PHX-POCxxx-User20), **Password:** *<Provided by Instructor>*

RTP
---
**Non-Employees** - **Username:** RTP-POCxxx-User01 (up to RTP-POCxxx-User20), **Password:** *<Provided by Instructor>*

Employee Pulse Secure VPN
..........................

https://sslvpn.nutanix.com - Use your CORP credentials

Non-Employee Pulse Secure VPN
..............................

1) If client already installed skip to step 5
2) To download the client, login to https://xlv-uswest1nutanix.com or https://xlv-useast1.nutanix.com using the supplied user credentials
3) Download and install client
4) Logout of the Web UI
5) Open client and ADD a connection with the following details:

Type: Policy Secure (UAC) or Connection Server(VPN)
Name: X-Labs - PHX
Server URL: xlv-uswest1.nutanix.com

OR

Type: Policy Secure (UAC) or Connection Server(VPN)
Name: X-Labs - RTP
Server URL: xlv-useast1.nutanix.com

6) Once setup, login with the supplied credentials
