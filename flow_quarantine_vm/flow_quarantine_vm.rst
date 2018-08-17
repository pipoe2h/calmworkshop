.. _flow_quarantine_vm:

-------------------
Flow: Quarantine VM
-------------------

Overview
++++++++

.. note::

  Estimated time to complete: 30-40 MINUTES

In this exercise you will enable Nutanix Flow, formally known as Microsegmentation, and create the VMs to be used throughout the remaining Flow exercises, **if you have not cloned the VMs already as part of the Lab - Deploying Workloads exercise**.

As part of this exercise, you will place a VM into quarantine and observe the behavior of the VM. You will also inspect the configurable options inside the quarantine policy and create a category with different values. Then you will create and implement an isolation security policy that uses the newly created category in order to restrict unauthorized access.

Finally, you will create an application category named **app-abc**, assign the **AppType: app-abc** category to your application VM, which in this exercise is the **flow-abc-5** VM, and create a security policy to restrict the application VM from receiving ICMP ping requests from VMs outside of the **programs-abc: sales-abc** category.
