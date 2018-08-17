.. _flow_enable:

-------------
Flow: Enable
-------------

Overview
++++++++

.. note::

  Estimated time to complete: 30-40 MINUTES

In this exercise you will enable Nutanix Flow, formally known as Microsegmentation, and create the VMs to be used throughout the remaining Flow exercises, **if you have not cloned the VMs already as part of the Lab - Deploying Workloads exercise**.

As part of this exercise, you will place a VM into quarantine and observe the behavior of the VM. You will also inspect the configurable options inside the quarantine policy and create a category with different values. Then you will create and implement an isolation security policy that uses the newly created category in order to restrict unauthorized access.

Finally, you will create an application category named **app-abc**, assign the **AppType: app-abc** category to your application VM, which in this exercise is the **flow-abc-5** VM, and create a security policy to restrict the application VM from receiving ICMP ping requests from VMs outside of the **programs-abc: sales-abc** category.

Enabling Microsegmentation
++++++++++++++++++++++++++

Open https://<Prism-Central-IP>:9440/ in a browser and log in.

From the navigation bar, click the question mark at the top right corner and expand the **New in Prism Central** section of the menu.

Click **Microsegmentation**.

Select the **Enable Microsegmentation** check box within the **Enable Microsegmentation** dialog box.

.. figure:: images/enable_flow.png

.. note::

  Flow can only be enabled once per Prism Central instance. If **Microsegmentation** displays a green check mark next to it, that means Microsegmentation has already been enabled for the Prism Central instance being used.

Click **Enable**

.. figure:: images/enable.png

Create Five VMs
+++++++++++++++

.. note::

  Skip this VM creation section if you have already created the Flow VMs as part of the Lab - Deploying Workloads exercise.

Now you will create the **five** virtual machines you will use to test the capabilities of Nutanix Flow. Create these virtual machines from the base VM in Prism Central called CentOS.

In **Prism Central > Explore > VMs**, click **Create VM**.

Fill out the following fields and click **Save**:

- **Name** - flow-<your_initials>-1
- **Description** - Flow testing VM
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
  - **IP Address** - *10.21.XX.42*
  - Select **Add**

Clone the other four VMs:
-------------------------

Take that VM and clone it four times to have a total of five VMs named as follows:

flow-<your_initials>-1
flow-<your_initials>-2
flow-<your_initials>-3
flow-<your_initials>-4
flow-<your_initials>-5

Select the **flow-<your_initials>-1** VM and click **Actions > Clone**.

- **Number of Clones** - 4
- **Prefix Name** - flow-<your_initials>-
- **Starting Index Number** - 2

Select the five newly created Flow VMs and click **Actions > Power on**.

.. figure:: images/flow_vms_2.png

Takeaways
+++++++++

- Microsegmentation is a decentralized security framework included from within Prism Central.
- It offers additional protection against malicious threats that originate from within the data center and spread laterally, from one machine to another.
- Once Microsegmentation is enabled in the cluster, VMs can be easily protected through Security Policies as created in the Prism Central UI. These function as labels that can easily be applied to VMs without any additional network setup.
