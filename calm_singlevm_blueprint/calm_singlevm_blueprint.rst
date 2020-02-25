.. _calm_singlevm_blueprint:

------------
Infrastructure as a Service (Calm Single VM Blueprint)
------------

.. note::

  Estimated time to complete: **30 MINUTES**

Overview
++++++++

Creating Single VM Blueprint (CentOS)
++++++++++++++++++++++++++

In this exercise you will explore the basics of Nutanix Calm by building and deploying a Blueprint that installs and configures a single service, MySQL, on a CentOS image.

#. Within the Calm UI, select |blueprints| **Blueprints** in the left hand toolbar to view and manage Calm blueprints.

   .. note::

     Mousing over an icon will display its title.

#. Click **+ Create Blueprint > Single VM Blueprint**.

#. Fill out the following fields:

   - **Name** - *initials*-CalmSingle
   - **Project** - *initials*-Calm

   .. figure:: images/calm_singlevm_01.png

#. Click **VM Details >**

#. Fill out the following fields:

   - **Name** - *CentOSAHV*
   - **Cloud** - *Nutanix*
   - **Operating System** - *Linux*

   .. figure:: images/calm_singlevm_02.png

#. Click **Variables >**

#. Add the following variables (**Runtime** is specified by toggling the **Running Man** icon to Blue):

   +------------------------+-------------------------------+------------+-------------+
   | **Variable Name**      | **Data Type** | **Value**     | **Secret** | **Runtime** |
   +------------------------+-------------------------------+------------+-------------+
   | USER_INITIALS          | String        | xyz           |            |      X      |
   +------------------------+-------------------------------+------------+-------------+
   | PASSWORD               | String        |               |     X      |      X      |
   +------------------------+-------------------------------+------------+-------------+

   .. figure:: images/calm_singlevm_03.png

#. Click **VM Configuration >**

#. Fill out the following fields:

   - **VM Name** - @@{USER_INITIALS}@@-centos-@@{calm_time}@@

   .. note::
      This defines the name of the virtual machine within Nutanix. We are using macros (case sensitive) to use the variables values as inputs. This approach can be used to meet your naming convention.

   - **vCPUs** - *2*
   - **Cores per vCPU** - *1*
   - **Memory (GiB)** - *4*
   - Select **Guest Customization**
   
     - Leave **Cloud-init** selected and paste in the following script
   
       .. code-block:: bash
   
         #cloud-config
         users:
           - name: centos
             sudo: ['ALL=(ALL) NOPASSWD:ALL']
         chpasswd:
           list: |
             centos:@@{PASSWORD}@@
           expire: False
         ssh_pwauth: True
   
   .. figure:: images/calm_singlevm_04.png
   
   - **Image** - CentOS-7-x86_64-GenericCloud
   - Select **Bootable**

   .. figure:: images/calm_singlevm_05.png

   - Select :fa:`plus-circle` along **Network Adapters (NICs)**
   - **NIC 1** - Primary
   
   .. figure:: images/calm_singlevm_05b.png

#. Click **Save**

#. Click **Launch** at the top of the Blueprint Editor.

#. Fill out the following fields:

   .. note::
      A single Blueprint can be launched multiple times within the same environment but each instance requires a unique **Application Name** in Calm.

   - **Name of the Application** - *initials*-CalmCentOS-1
   - **USER_INITIALS** - *initials*
   - **PASSWORD** - *any password*

#. Click **Create**

   .. figure:: images/calm_singlevm_06.png

   You will be taken directly to the **Applications** page to monitor the provisioning of your Blueprint.

#. Click **Audit > Create** to view the progress of your application.

#. Click **Substrate Create > CentOSAHV - Provision Nutanix** to view the real time output of the provisioning.

   .. figure:: images/calm_singlevm_07.png

   Note the status changes to **Running** after the Blueprint has been successfully provisioned.

   .. figure:: images/calm_singlevm_08.png

Takeaways
+++++++++

- The Single VM Blueprint Editor provides a simple UI for modeling IaaS blueprints in less than five minutes.
- Blueprints are tied to SSP Projects which can be used to enforce quotas and role based access control.
- Variables allow another dimension of customizing an application without having to edit the underlying Blueprint.
- There are multiple ways of authenticating to a VM (keys or passwords), which is dependent upon the source image.
- Virtual machine status can be monitored in real time.

.. |proj-icon| image:: ../images/projects_icon.png
.. |mktmgr-icon| image:: ../images/marketplacemanager_icon.png
.. |mkt-icon| image:: ../images/marketplace_icon.png
.. |bp-icon| image:: ../images/blueprints_icon.png
.. |blueprints| image:: images/blueprints.png
.. |applications| image:: images/blueprints.png
.. |projects| image:: images/projects.png
