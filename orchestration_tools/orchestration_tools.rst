***************************************************
Orchestration/Change Management Tools - Comparison
***************************************************


Introduction
************

Development, deployment and maintenance of virtual servers requires a sophisticated set of tools. Updating your application is 
only one part of the process - next is managing the deployment of that application across servers. This is known as cloud 
orchestration or deployment automation. The terminology is fluid but the concept is the same - your application and all of 
the infrastructure behind it updated on every VM it lives on. This mission of cloud orchestration typically falls under 
DevOps.

Currently the leading tools in the Configuration Management marketplace are Puppet, Chef, and Ansible. While there’s no 
de-facto leader in the marketplace, each tool has its host of dedicated users. Chef’s celebrity tech companies are Facebook, 
Nordstrom, & Target, while Puppet is used by Walmart, 1-800 Flowers, & Wells Fargo. Ansible, released in 2013, is the newest 
of the three and is used by Capital One, Splunk, and NEC.

Selecting the best cloud configuration management system is a daunting task, regardless of whether you run servers on a 
single platform like Azure or across multiple vendors.

Difference between Orchestrate & Automate
*****************************************

**Orchestration:**

A very good, simple example of orchestration is requesting an IP. You may have inputs around a subnet, port group name, or server type along with credentials to gain access to the IPAM solution. The output is an IP that has been reserved in DNS and is ready to use in seconds. Within that process there have been various steps of logic taken in finding the subnets, verifying there is available capacity, reserving the IP, and sending the end-user that IP. There is also logic that if the flow fails for various reasons (e.g.,, out of capacity) the end-user will be notified with a useful error that can then be acted upon. On the decommission/removal task front, the aforementioned flow would have an orchestrated workflow to do the cleanup of the reserved resources; in this case, a DNS entry.

**Automation:**

HRaaS (Human Resources as a Service) – An HR person logs into a portal and submits a request for a new employee. The only info she provided was the new username along with their first and last name. This process will reach out to LDAP to create the username, reach out to exchange to create a mailbox, send a request to the badging appliance to allow their LDAP GUID access to the building, and then finally send an email over to the badging department with their name, username, and GUID to make the badge so it is ready on the new employee’s first day.

The HR person wasn’t asked for port numbers or the GUID, and a ticket wasn’t dropped in someone’s lap halfway though the process to sit on for three days, either. Instead, the entire process was completed end-to-end and HR is only waiting on the physical badge to be created. Also, this process touched a few very important systems throughout the enterprise and no one was prompted for a username or password, as everything was managed by the disparate system owners.

**Orchestrate, orchestrate, orchestrate!**

Every IT organization should be using an orchestrator. Simply put, you can orchestrate tasks that take a human minutes or hours in (milli) seconds with 100% repeatability. Microsoft and VMware both have “free” orchestrators with their products: System Center Orchestrator and vRealize Orchestrator that is currently bundled with vCenter (Yes, vCenter)!

**Pick a tool – One tool!**

I’ve seen IT organizations where the networking team is using one tool, the infrastructure teams are using two different tools, and the AppDev teams are using another tool, where there is obviously no strategic direction. These tools are usually not free and more importantly, the time it takes to train your team is a significant investment. So now, you have various teams in an organization learning different tools and all fighting to accomplish nearly the same thing.

Puppet Overview
***************

Puppet is a solution that lets you control whats installed/configured on multiple machines from a single central machine. This single central machine is referred to as the “Puppet Master”, and the machines it controls are called “Puppet Agents” (aka nodes or slaves).

In a puppetised environment, each agent checks-in with the puppet-master to see if it is set up the way it’s supposed to. If the answer is yes then nothing happens, if not, then the puppet master tells the agent what it should look like, then the node makes changes to itself accordingly to reflect this.

.. figure:: http://s3.nutanixworkshops.com/calm/orchestration/image1.png

The way this works is that on the puppet master you can define a “Desired State” for each of your nodes.   This desired state is declared in a syntax similar to a hash table’s syntax.

If a node doesn’t resemble a desired state, then we say that a “drift” has occurred.   A drift is identified every 30 minutes, where the following happens:

- The node sends it current setup info (referred to as “FACTS”) to the Puppet master.
- The Puppet master uses the facts to compile a “catalog”. This catalog contains detailed data about how the node should be configured.
- The Puppet master sends the catalog back to the node.
- The node enforces the changes as described in the the catalog
- The node then sents a “Report” back to the puppet master. You can view these reports and integrate them with other systems.

Chef Overview
*************

Chef is a configuration management tool for dealing with machine setup on physical servers, virtual machines and in the cloud. Many companies use Chef software to control and manage their infrastructure including Facebook, Etsy, Cheezburger, and Indiegogo.

.. figure:: http://s3.nutanixworkshops.com/calm/orchestration/image3.png

Chef helps solve this problem by treating infrastructure as code. Rather than manually changing anything, the machine setup is described in a Chef recipe.

- Chef repository contains all your Chef artifacts. It’s recommended to have it in your version control system.  Developer machine issues knife commands. knife allows you to push Chef artifacts to Chef server or query information about your infrastructure from Chef server. You can also use knife to manually execute commands on nodes in your infrastructure.

- Chef server is a central point of Chef architecture. It has all your cookbooks and settings. It tracks information about all nodes in your infrastructure.

- Nodes are machines managed by Chef. Nodes pull cookbooks and configuration from Chef server.

- Collections of recipes are stored in a cookbook. One cookbook should relate to a single task, but can have a number of different server configurations involved (for example a web application with a database, will have two recipes, one for each part, stored together in a cookbook).

**Chef Server**

The Chef server stores cookbooks, the policies that are applied to nodes, and metadata that describes each registered node that is being managed by the chef-client.

Nodes use the chef-client to ask the Chef server for configuration details, such as recipes, templates, and file distributions.

The chef-client then does as much of the configuration work as possible on the nodes themselves

**Chef Client**

It is a provisioning which works on server.

Agent that runs locally on every node that is under management by Chef. When a chef- client is run, it will perform all of the steps that are required to bring the node into the expected state, including:

- Registering and authenticating the node with the Chef server
- Building the node object

- Synchronizing cookbooks

- Compiling the resource collection by loading each of the required cookbooks, including recipes, attributes, and all other dependencies

- Taking the appropriate and required actions to configure the node

- Looking for exceptions and notifications, handling each as required

The client will then check in every now and again to make sure that no changes have occurred, and nothing needs to change. If it does, then the client deals with it. Patches and updates can be rolled out over your entire infrastructure by changing the recipe. No need to interact with each machine individually.

**Cookbooks**

Cookbooks are the most important Chef artifacts. They contain default configuration, configuration file templates, resource providers, helper scripts, files and recipes. The most interesting part of cookbook is recipes. Recipes are sets of instruction that perform some kind of procedure – usually installs and configures some service but not necessarily.

There is a Chef server which stores each of these cookbooks and as a new chef client node checks in with the server, recipes are sent to tell the node how to configure itself.

**Recipes**

It is the most fundamental configuration element within the organization. A recipe:

- It Is authored using Ruby, which is a programming language designed to read and behave in a predictable manner

- Is mostly a collection of resources, defined using patterns (resource names, attribute-value pairs, and actions); helper code is added around this using Ruby, when needed

- Must define everything that is required to configure part of a system

- Must be stored in a cookbook

- May be included in a recipe

- May use the results of a search query and read the contents of a data bag (including an encrypted data bag)

- May have a dependency on one (or more) recipes

- May tag a node to facilitate the creation of arbitrary groupings

- Must be added to a run-list before it can be used by the chef-client.  Is always executed in the same order as listed in a run-list

**Knife**

Chef's command-line tool called to interact with the Chef Server.

- Use it for uploading cookbooks and managing other aspects of Chef.

- Command-line tool that provides an interface between a local chef-repo and the Chef server. knife helps users to manage: Nodes,Cookbooks and recipes

**Roles**

Chef roles define a types of nodes in your infrastracture and are stored as json data (data bags), inlcuding encrypted data. They usually correspond to a service that node is running. You can use roles to group nodes. A single node can also be in multiple roles. Typical Rails application deployment infrastructure consists of the following roles:

- Database server
- Memcache/Redis server
- Application server
- Load balancer

**Data Bags**

Global variable that is stored as JSON data and is accessible from a Chef server.

- It can be created in two ways: using knife or manually.

- It helps you manage and configure nodes information on the server in an easy way.

Ansible Overview
****************

Ansible can be thought of as general purpose tool for managing servers. This means that Ansible can be used as a:

- Server provisioning tool – build new vm, e.g. in aws. Ansible can also do orchestration, i.e. build+configure servers in a specific sequence. Ansible has a number of modules for communicating with aws, azure, google cloud, openstack,…etc.

- Configuration Management tool – i.e. configure OS and middleware tier.

- Deployment tool – i.e. installing and configuring software that has been written in-house.

**Architecture**

Ansible has a controller-client type architecture, where you have one server (aka the controller) controlling lots of other servers (aka clients). However in ansible, you don’t need to install any ansible specific software on the client’s themselves. You only install ansible on the controller. I.e. it is an agentless architecture.  The controller communicates with all the clients via standard ssh.

.. figure:: http://s3.nutanixworkshops.com/calm/orchestration/image2.png

Ansible playbooks are essentially 1 or more scripts written in yaml. The puppet equivalent to playbooks is puppet manifests.

In order for a client to be controlled by the Ansible server, it needs to have the following minimum requirements:
– SSH daemon enabled (this is normally the case anyway)
– python is installed

**Stengths**

- Easy to read syntax

- It is a multi-purpose tool – it can do provisioning, environment orchestration, configuration management tool, deployment tool.

- You don’t need to install or configure anything on the clients. The clients needs to have ssh, and a relatively recent version of python.

- Ansible is pushed based – clients don’t need to have any services running to periodically do an ansible run. Instead you trigger the run from the controller.

- Easy to build multiple controllers, the clients are not configured to communicate with a particular controller. Hence when number of clients goes up to thousands, then you can quickly build new controllers to handle.

- Can execute adhoc shell commands on the clients.

- Builtin modules (puppet’s equivalent of resource types). These modules behaves idempotently to bring a ensure a stage.

**Weaknesses**

- Abstractions are kept to a minimum, e.g. for installing packages on rhel based OS, you need to use the yum’s built-in module, whereas for ubuntu, you use apt’s built-in module instead

Puppet+Chef+Ansible: Installation & Ease of Use
***********************************************

**Puppet**

With Puppet, you set up a master server and install Puppet agents on each of your nodes (individual VMs). To install on 
individual VMs, you SSH into each one and run a script. On initial setup of that master server, you have the option to 
install the Puppet console and the master server on the same machine. Otherwise, you can set up a Puppet console on your 
development machine, and keep the master server in the cloud. Puppet does have a steep learning curve, though the Puppet 
Forge Community offers great administrative templates, modules, and discussions.

**Chef**

To set up Chef, you’ll use knife, Chef’s command-line tool that provides an interface between a workstation on your 
development machines and your Chef servers. You create cookbooks (instructions for automation), define environments, set 
roles, and more that are all pushed to a central Chef Server. That main Chef Server contains information on every node in 
your system, and Chef clients runs independently on each of these nodes. If you want to add more nodes, you can do so via 
knife bootstrap, passing in an IP address and password.

**Ansible**

Ansible is designed to be light and fast, so there’s no installation on each node. Instead, nodes are 
added via a config file on your master server, with SSH authorized keys added to each node. Ansible offers a variety of 
consulting and training services.


Puppet+Chef+Ansible: User Interface
***********************************

Open Source Puppet only has a CLI, while Puppet Enterprise has the CLI and a web UI. The bread and butter of Puppet are 
modules which contain the code that configures and manages your nodes. Installing modules is easy via the command line, but 
for anything more involved like creating users for access control and creating node groups, the Puppet Console is necessary.


**Chef vs Puppet**

Chef has a web UI, Chef Manage, but you’ll be doing most of your work via the command line with Knife. Chef is built with 
Ruby, so if you’re familiar with Rails, the syntax is straightforward. When you want to add new libraries to your cookbooks 
(Chef’s equivalent of Puppet’s modules), you add it as a dependency - just like adding gems.

**Ansible**

There’s Ansible Tower, Ansible’s enterprise edition and it’s web UI. It’s easier to configure and manage than Chef or 
Puppet’s web interfaces. Tower also makes use performance analytics, along with compliance and security functions from Red 
Hat.


Puppet+Chef+Ansible: Code Base
******************************

For these cloud orchestration platforms, we judged code bases on the breadth of modules, preconfigured system configurations, 
and community created tools. Essentially, how much code is out there that my team and I can use to get this into our 
infrastructure?

**Puppet**

Puppet has the Puppet Forge, which is expansive, hovering around five thousand modules. Here, modules are separated by Puppet 
Supported (built by Puppet) and Puppet Approved, the top rated modules created by the community. Puppet recently put out a 
module supporting Azure servers, so if you’re in Microsoft land, there’s a place at the table for you. Like Chef, installation
is straightforward via your terminal. New modules are added to your Puppetfile.

**Chef**

Chef has the Chef Supermarket which contains over three thousand cookbooks contributed by over seventy-thousand chefs. 
Branding words aside, this means that there’s a lot of available modules you can install on your nodes to simplify system 
configurations. There’s the standard ones you’d expect: nginx, mysql, and docker. But there’s also cookbooks for 1password, 
redis, and even homebrew. Even though there’s only three thousand modules, the community is strong and modules receive 
consistent updates. Developers with Ruby experience tend to adopt Chef or Puppet so if that’s your language, easing into 
using pre-configured modules from their open source communities makes the decision easy.

**Ansible**

The Ansible Galaxy community is a helpful resource for tools and templates, and has more than three times as many 
contributors than the other tools in this comparison, and uses Ansible uses YAML Playbooks instead of recipes. Here, 
modules are called Ansible Roles. While we don’t have the exact number of roles available, there’s over a thousand roles 
just for mySQL, so you’ll find your flavor of SQL no matter what you’re looking for. There’s even a module for installing 
PHPmyAdmin. Language-wise, Ansible was built on Python. One thing I do like about the Galaxy interface is that it’s easy to 
filter by multiple categories and module versions.



Puppet+Chef+Ansible: Scalability
********************************

This is what matters in the end - when you’re scaling systems to thousands and tens of thousands of nodes, you want the 
ability to keep every VM under the fold.

**Puppet**

Similar to Ansible, it’s fairly easy to add and remove server nodes to Puppet. The Puppet Master server component can 
quickly pick up on new server Puppet Agents to distribute commands for updates and configuration. Most services on Puppet 
run over HTTP like web applications, so it’s easy to create a load balancer with high availability/performance and you won’t 
see a drop in efficiency.

**Chef**

Chef Nodes are bootstrapped by the Chef Workstation and managed by Chef agents. Adding new nodes is done through your 
workstation machine, which adds them to a master list on the Chef master Server. Each of these nodes has a ‘run-list’, 
which is basically everything it needs to get up to the desired state, so setup is automated after that initial point. 
Chef gets updates from each server node every 30 minutes, and logs the status of the server for compliance requirements.

**Ansible**

Ansible has powerful orchestration capabilities. As mentioned before - there’s no serious installation on each node. 
As long as you have SSH authorized keys for each node, you can add as many as you’d like directly from the config file on 
the master server.

Summary
*******

So in the end, which platform is best? Well, it depends on your needs. 
Personally, I like Ansible because I came from a Python development background, and AWS has created OpsWorks for Ansible, 
which makes it easier to integrate into your system if you’re using AWS exclusively.

The clear factor here is that all three (Chef, Puppet, and Ansible) of those cloud configuration management tools all have 
expansive communities and modules, so there’s no worry on a lack of resources.

Many companies run multiple cloud management solutions, and just as many run multiple public, private and/or hybrid cloud 
environments. It’s important to evaluate multiple open source solutions before investing in an enterprise license. While all 
three limit you to around ten nodes on the open source versions, it’s a great way to test a cloud management solution being 
implemented in one of your divisions.


.. |image0| image:: orchestration/media/image1.png
.. |image1| image:: orchestration/media/image2.png
.. |image2| image:: orchestration/media/image3.png
