.. _calm_enable:

------------
Calm: Enable
------------

Overview
++++++++

.. note::

  Review :ref:`calm_basics` before proceeding with the lab to familiarize yourself with the UI and common terminology used in Nutanix Calm.

  Estimated time to complete: **170 MINUTES**

In this exercise you will enable Nutanix Calm and configure a Project to contain your Blueprints and Applications created throughout the Workshop.

Enabling App Management
+++++++++++++++++++++++

In this exercise you will enable Nutanix Calm and configure a Project to contain your Blueprints and Applications created throughout the Workshop.

Open \https://*<Prism-Central-IP>*:9440/ in a browser and log in.

From the navigation bar, select **Calm** (if you're running PC <5.8.1, then select **Apps**).

Click **Enable**.

.. figure:: images/581enable1.png

Select **Enable App Management** and click **Save**.

.. note:: Nutanix Calm is a separately licensed product that can be used with Acropolis Starter, Pro, or Ultimate editions. Each Prism Central instance can manage up to 25 VMs for free before additional licensing is required.

.. figure:: images/581enable2.png

You should get verification that Calm is enabling, which will take 5 to 10 minutes.

.. figure:: images/581enable3.png

Adding Active Directory
+++++++++++++++++++++++

While we're waiting for Calm to enable, we'll add an Active Directory server.  While this isn't required for basic Calm use, it is required to do any Role Based Access Control, so it's a good idea to get set up.

Click the **Gear Icon** and then **Authentication**.

.. figure:: images/581enable4.png

In the pop up, click **New Directory**.

.. figure:: images/581enable5.png

Fill out the following fields and click **Save**:

- **Directory Type** - Active Directory
- **Name** - NTNXLAB
- **Domain** - ntnxlab.local
- **Directory URL** - ldaps://*<DC-VM-IP>*
- **Username** - Administrator@ntnxlab.local
- **Password** - nutanix/4u

.. figure:: images/581enable6.png

Refresh the browser and select **Calm** from the navigation bar.  If Calm is still enabling, wait another minute, and try again.

.. figure:: images/581enable7.png

Creating A Project
++++++++++++++++++

Projects are the logical construct that integrate Calm with Nutanix's native Self-Service Portal (SSP) capabilities, allowing an administrator to assign both infrastructure resources and the roles/permissions of Active Directory users/groups to specific Blueprints and Applications.

Click + Create Project

Select |proj-icon| **Projects** from the sidebar.

.. figure:: images/581enable8.png

Fill out the following fields:

- **Project Name** - Calm-*initials*
- **Description** - Calm-*initials*

Under **Users, Groups, and Roles**, click **+ User**.

Fill out the following fields and click **Save**:

- **Name** - SSP Admins
- **Role** - Project Admin

Click **+ User**, fill out the following fields and click **Save**:

- **Name** - SSP Developers
- **Role** - Developer

Click **+ User**, fill out the following fields and click **Save**:

- **Name** - SSP Power Users
- **Role** - Consumer

Click **+ User**, fill out the following fields and click **Save**:

- **Name** - SSP Basic Users
- **Role** - Operator

Under **Infrastructure**, fill out the following fields:
- **Select which resources you want this project to consume** - Local only
- **AHV Cluster** - *<Cluster Name>*

Under **Network**, select the **Primary** and if available, the **Secondary** networks. Select :fa:`star` for the **Primary** network to make it the default virtual network for VMs in the **Calm** project.

Click **Save**.

.. figure:: images/enable7.png

.. note::

  Click `here <https://portal.nutanix.com/#/page/docs/details?targetId=Nutanix-Calm-Admin-Operations-Guide-v56:nuc-roles-responsibility-matrix-c.html>`_ to view the complete matrix of default SSP roles and associated permissions.

Takeaways
+++++++++

- Nutanix Calm is a fully integrated component of the Nutanix stack. Easily enabled, highly available out of the box in a Scale Out Prism Central deployment, and takes advantage of non-disruptive One Click upgrades for new features and fixes.
- By using different projects assigned to different clusters and users, administrators can ensure that workloads are deployed the right way each time.  For example, a developer can be a Project Admin for a dev/test project, so they have full control to deploy to their development clusters or to a cloud, while having Read Only access to production projects, allowing them access to logs but no ability to alter production workloads.

.. |proj-icon| image:: ../images/projects_icon.png
.. |mktmgr-icon| image:: ../images/marketplacemanager_icon.png
.. |mkt-icon| image:: ../images/marketplace_icon.png
.. |bp-icon| image:: ../images/blueprints_icon.png
