-------------
Glossary
-------------

Nutanix Core
++++++++++++

AOS
...

AOS stands for Acropolis Operating System, and it is the OS running on the Controller VMs (CVMs).

Pulse
.....

Pulse provides diagnostic system data to Nutanix customer support teams so that they can deliver proactive, context-aware support for Nutanix solutions.

Prism Element
.............

Prism Element is the native management plane for Nutanix. Because its design is based on consumer product interfaces, it is more intuitive and easier to use than many enterprise application interfaces.

Prism Central
.............

Prism Central is the multicloud control and management interface for Nutanix. Prism Central can manage multiple Nutanix clusters and serves as an aggregation point for monitoring and analytics.

Node
....

Industry standard x86 server with server-attached SSD and optional HDD (All Flash & Hybrid Options).

Block
.....

2U rack mount chassis that contains 1, 2 or 4 nodes with shared power and fans, and no shared no backplane.

Storage Pool
............

A storage pool is a group of physical storage devices including PCIe SSD, SSD, and HDD devices for the cluster.

Storage Container
.................

A container is a subset of available storage used to implement storage policies.

Anatomy of a Read I/O
.....................

Performance and Availability

- Data is read locally
- Remote access only if data is not locally present

Anatomy of a Write I/O
......................

Performance and Availability

- Data is written locally
- Replicated on other nodes for high availability
- Replicas are spread across cluster for high performance

Nutanix flow
++++++++++++

Application Security Policy
...........................

Use an application security policy when you want to secure an application by specifying allowed traffic sources and destinations.

Isolation Environment Policy
............................

Use an isolation environment policy when you want to block all traffic, regardless of direction, between two groups of VMs identified by their category. VMs within a group can communicate with each other.

Quarantine Policy
.................

Use a quarantine policy when you want to isolate a compromised or infected VM and optionally want to subject it to forensics. You cannot modify this policy. The two modes to quarantine a VM are Strict or Forensic.

Strict: Use this value when you want to block all inbound and outbound traffic.

Forensic: Use this value when you want to block all inbound and outbound traffic except the traffic to and from categories that contain forensic tools.

AppTier
.......

Add values for the tiers in your application (such as web, application_logic, and database) to this category and use the values to divide the application into tiers when configuring a security policy.

AppType
.......

Associate the VMs in your application with the appropriate built-in application type such as Exchange and Apache_Spark. You can also update the category to add values for applications not listed in this category.

Environment
...........

Add values for environments that you want to isolate from each other and then associate VMs with the values.
