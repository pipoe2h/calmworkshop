.. _calm_enable:

------------
Calm: Enable
------------

Overview
++++++++

.. note::

  Review :ref:`calm_basics` before proceeding with the lab to familiarize yourself with the UI and common terminology used in Nutanix Calm.

  Estimated time to complete: **10 MINUTES**

In this exercise you will enable Nutanix Calm.

Enabling App Management
+++++++++++++++++++++++

Calm is built into Prism Central and requires no additional appliances or consoles to manage. Before you can begin managing apps in your environment with Calm, the service must be enabled.

.. note::

  Calm can only be enabled once per Prism Central instance. If **Enable app management** displays a green check mark next to it, that means Calm has already been enabled for the Prism Central instance being used. Proceed to :ref:`calm_projects`.

#. In **Prism Central**, click the **?** drop down menu, expand **New in Prism Central** and select **Enable app management**.

#. Click **Enable**.

   .. figure:: images/510enable1.png

#. Select **Enable App Management** and click **Save**.

   .. note:: Nutanix Calm is a separately licensed product that can be used with Acropolis Starter, Pro, or Ultimate editions. If you want to test Calm, there is a 60 days trial starting when you enable it.

   .. figure:: images/510enable2.png

#. You should get verification that Calm is enabling, which will take 5 to 10 minutes.

   .. figure:: images/510enable3.png

Adding Active Directory
+++++++++++++++++++++++

While we're waiting for Calm to enable, we'll add an Active Directory server.  While this isn't required for basic Calm use, it is required to do any Role Based Access Control, so it's a good idea to get set up.

#. Click the **Gear Icon** and then **Authentication**.

   .. figure:: images/510enable4.png

#. In the pop up, click **New Directory**.

   .. figure:: images/510enable5.png

#. Fill out the following fields and click **Save**:

   - **Directory Type** - Active Directory
   - **Name** - NTNXLAB
   - **Domain** - ntnxlab.local
   - **Directory URL** - ldaps://*<DC-VM-IP>*
   - **Search Type** - Non Recursive
   - **Username** - Administrator@ntnxlab.local
   - **Password** - nutanix/4u

   .. figure:: images/510enable6.png

#. Refresh the browser and select **Calm** from the navigation bar.  If Calm is still enabling, wait another minute, and try again.

   .. figure:: images/510enable7.png

Takeaways
.........

Calm Architecture:

- Calm runs as a containerised application within Prism Central, **nucalm** and **epsilon** containers.
- Enable Calm is 1-click task. **In 10 minutes Calm is ready** versus other solutions in the market that take weeks or months of professional services engagement just to start.
- Because Calm runs on containers, upgrading to new versions is 1-click task. Again, other solutions in the market require weeks of planning due to several components and dependencies with other products.
- Calm provides 60-day trial.
