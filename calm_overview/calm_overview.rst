*************
Calm Overview
*************

Overview
********

Calm allows Nutanix Enterprise customers to seamlessly select, provision, deploy & manage their Business Apps across all their infrastructure, both private and public cloud. Calm ties together a Marketplace, App Lifecycle, Monitoring & Remediation by providing single control-point for managing heterogeneous infrastructure, be it VMs or containers, or even baremetal servers. Calm will eventually support all the components required to manage a complete Software Defined Data Center. 

.. figure:: http://s3.nutanixworkshops.com/calm/nucalm/image16.png

To enable adoption and encourage enterprises to use the NTNX platform, Calm will not restrict itself to Nutanix (AHV/Xi), but support multiple platforms used by customers so that customers get used to a single self-service and automation interface via which they can interact with all their infrastructure and use it as a bridge to move more and more into the Nutanix ecosystem and future offerings.

Prism Central VM sized depending on requirements

- Small: 12Gb + 4Gb for Calm.
- Large: 32Gb + 8Gb for Calm.

Calm is deployed alongside SSP in the Prism Central VM. Calm consumes multiple Nutanix internal services and is not a standalone component. By extension, users must have a Nutanix Prism Central VM to enable Calm functionality.

**Use Cases**

- Automation for complex applications
   - Not only provisioning, but also self service.
- Enable application self service for multiple teams
   - Setup Complex applications with a single click.
   - Quickly get dev/test environments ready to go.
- Single view to provision and manage hybrid clouds
   - Private hypervisors and public cloud together.


WHAT: Calm Components
***********************

.. figure:: http://s3.nutanixworkshops.com/calm/nucalm/image10.png

**Application-focus**

Calm is an application-centric view of IT infrastructure, as compared to the existing VM-centric views for most IT management planes. As IT evolves to microservices with a focus on self-service and the business user, the business increasingly consumes applications, not the VMs or containers underlying the application. The basic unit of creation within Calm is the application, with a single VM being a simpler application with n=1. Applications containing multiple VMs or containers are provisioned, managed and deleted as a set instead of independent units. 

Calm understands dependencies between components in an application, allowing it to manage and perform multi-VM operations at an application level. Changes like scale up for one component propagate across the application, with Calm resolving other tasks like editing load balancers appropriately.

1-Click application provisioning is possible with Calm’s application-focused interface, whether the application is a single VM or multiple VMs being provisioned in the backend. 

**Marketplace**

Calm contains a global Marketplace which is a marketplace to publish and consume applications. While initially Nutanix and select partners will publish applications to this Marketplace, over time, NTNX will open up this Marketplace to a larger group of partners and developers.

Publishers can upload their application designs (a.k.a. blueprints) to the Marketplace. After review, these will be published and made available to consumers who choose to select and launch these applications within thier infrastructure. 

Application blueprints contain the instrumentation to provision the application across 1 or more platforms, procedures to upgrade, scale up and scale down the app as well as other common operations performed on the application by operations and devops teams. 

Admins can whitelist blueprints, design and publish their own application blueprints for internal consumption, and be able to launch these blueprints across multiple-clouds.

**Multi-cloud**

Calm will eventually support multiple hypervisors and cloud providers, while being Nutanix-first in terms of supporting AHV, Xi, and AWS for a great user experience. Notions for other providers like AWS, Azure etc would be supported, whether they exist in AHV/Xi today or not. E.g. A user can use Calm across AHV and AWS, but won’t get the feature goodness or convenience offered by the deeper AHV and Xi integration from Nutanix.

Provider support will be based on customer requirements, with initial targets being AHV/AWS (1.0), followed quickly by ESXi, Xi and then other platforms (Openstack, AzureStack,…).

**App Mobility**

Calm also enables Nutanix’s App Mobility Fabric as all of its features come together. For applications where we have access to the storage layer (on AHV/Xi), we’ll be able to leverage deeper features of the Nutanix platform to provide seamless mobility across hybrid cloud for customers. On platforms where we have restricted access to storage, the application ‘moves’ may involve redeploying the application on the new cloud based on a triggering event. The exact mechanism and scope for this is still TBD.

**Runbooks**

Using the Calm orchestration engine (a.k.a. Epsilon), Calm enables runbook orchestration across services and applications in the customer’s hybrid cloud infrastructure. Runbooks can be triggered both manually by end-users based on role-based access or hooked up to monitoring and service-desk tools for automated execution. Calm will display streaming logs for activities being performed and maintain audit logs for all operations performed by users in the system.

The runbook engine will also be called out to by internal entities within the Nutanix system to perform orchestration tasks using its capabilities.

**Environments**

Calm provides support for multiple environments in the customer datacenter (dev/QA/staging/production etc). Each environment will have its own constraints and the same blueprint may be deployed at a different scale or on a different provider depending on the user role and environment requested. This will also enable the usage of Calm for building more complex CI/CD pipelines for customer infrastructure. 

**CI-CD Pipelines**

Calm enables continuous integration and deployment pipelines across multiple environments for customers. With potential Jenkins integration, customers will be able to track the progress of code commits across multiple environments for each application, and be able to have an automated process (with approvals) for end-to-end deployment across their infrastructure.

**Budgets**

Calm provides a chargeback and budgeting mechanism via the budgets entity. For private clouds (AHV/ESXi), it lets the user define the costs (per vCPU/GB RAM/GB storage) of infrastructure per cluster and builds a consumption model based on its usage by business groups. For public clouds (Xi/AWS), Calm tracks approximate usage via available platform APIs, showing overall expenditure across hybrid clouds as a single unified view. IT can add a surcharge to the public cloud cost to account for software licensing and management overhead that they may incur.

Quotas are supported in Calm v1.0, carried over from SSP. However, over time, NTNX expects to deprecate these and move customers over to thinking about all their application VMs and infrastructure in $ terms. 

**Policy Engine**

The Calm policy engine adds a global layer of policy-based controls to the self-service and automation interface. Multiple policy-types will be added over time, with custom policies also being made available to users so they can roll their own. The below is an indicative snapshot of the policies we can add, with more getting added to the system based on customer feedback.

- Expiry

Expiry policies control the lifetime of the applications provisioned using Calm. Admins can control and set this to a hard date or a relative value. Expiry extensions can be requested and must be approved by the admin of the system. 

- Underutilized Infra

Using monitoring hooks and data from platform APIs, users can set policies to scale down or shutdown/stop underutilized applications, saving IT resources on AHV nodes and $ on Xi. 

- Suspend & Archive

Underutilized or expired applications can be put into suspended mode and cleaned up after a set of time if not accessed again.

- Scheduler

A scheduler allows Calm users to schedule application-specific events to occur on a timed basis. This can include things like provision/deprovision/scale up/scale down etc as well as any runbooks that need to be executed periodically.

- Budget Policies

Budget policies control the behavior of the budget entity in the system. They can control what happens when a budget is exceeded (suspend/delete/require approvals) and can also be used to control which team gets to use which budget or related platform. 

- Approvals

Approval policies are used to request permissions for any specified event in the system. Approvals are a blocking action and must be resolved before the activity can proceed. Approvals will be in system as well as sent via email. Calm will integrate with ServiceNow approval flows and could potentially call out to other means like configured SMS gateways etc. 

- Notifications

Notifications in the Calm system are similar to approvals, but are non-blocking activities, using the same surfacing actions. These are used to notify admins and devops users of activities underway in the Calm system.

**Licensing**

Licensing for Calm: 

- Separate SKU, works with both Prism Starter & Pro

- Perpetual Free Tier (25VMs per customer)

- All Features enabled.

- Sold as VM Packs of 25VMs each:  $250/vm/yr (including support).  Customers don’t need to license for every VM, only the ones they want to automate via Calm.

- Uniform Pricing for Simplicity with Hybrid Cloud

WHY: Calm Reasoning
*********************

The business care about Apps, not VMs.  Managing Apps is challenging. Apps are complicated…. Application health is critical to meeting business demands and SLA's.  As apps become more and more comlpex, tools need to evovle to mange the copmlexity of deployment, monitoring, and scaling across varying enviornments.

.. figure:: http://s3.nutanixworkshops.com/calm/nucalm/image18.png

Hybrid Clouds add another layer of challenges.  Environments and plattforms are evolving faster than applications, where each platform or environment requires subject matter experts to manage them.  Calm incorporates instrumentation needed to manage this complexity from a single control-point. 

.. figure:: http://s3.nutanixworkshops.com/calm/nucalm/image19.png

**Application-Focus**

As Nutanix moves up the stack from the IT infrastructure team towards devops and then to the business user, NTNX will provide context that the business user understands. With an application focus, the end-user, who does not understand the specifics of public and private cloud, can request exactly the application that is needed. This does not assume any knowledge about how the application is architected or how many VMs or containers are being provisioned in the backend. A simple consumption model where the user files a request and is charged as per usage is what we aim to provide with the Calm interface. 

The Nutanix Enterprise OS abstracts away all these notions and bridges the gap between the private and the public cloud with a consumption focus.

**Marketplace**

One of the main challenges that hampers adoption of automation tooling is the initial bootstrapping and upfront work needed to save man-hours in the future. To enable an easy on-ramp, Calm has the ability to provide a library of readymade template blueprints consisting of commonly used applications. These can be consumed directly by customer DevOps or used as lego blocks and edited as per requirements to model custom enterprise applications.

The ability to quickly try out partner and third-party applications helps NTNX build a 2-sided marketplace with our users, enabling higher usefulness for the platform as a whole. This is a powerful model, since it also enables our end-users to quickly satisfy requests for modern applications from developers, without having to first do a month-long deep dive into how to get the specific application up and running.

**Multi-cloud**

Most enterprises are either already using multiple cloud providers or evaluating options across both newer and legacy infrastructure. Customers prefer to have a single automation plane across all their infrastructure, not just Nutanix AHV. Most of our customers will have both AHV and VMware, with Xi and upcoming AWS also in use. In such cases, Calm provides an onramp to our customers onto both AHV and Xi from other clouds. All NTNX Marketplace blueprints are configured for Nutanix as the primary choice. 

Having Calm as the common management plane also ensures that no matter what other provider the customer uses, the Nutanix management and automation plane still provides value to the customer.

**App Mobility**

Application mobility is a requirements as enterprise customers have multiple platforms in use. The ability to move applications across clouds, with or without downtime, is a powerful tool to enable users to adapt to changing compliance and scalability requirements. Enterprises are sensitive to possible lock-in to a cloud provider and app mobility allows them to move workloads across clouds. Also, DevOps teams don’t want to rewrite their automation frameworks for every new cloud platform.

**Runbooks**

Most applications used in the enterprise are custom or developed in-house. As a result, it becomes impossible to provide templates for such applications. Every large customer has their own process and architecture that is used to manage their applications and associated infrastructure. In such cases, the ability to define custom runbooks in addition to pre-packaged ones is a necessity to enable automation for all use-cases.  

**Environments**

Environments are a way for users to carve out applications and infrastructure based on its usage and restrict access permissions for different teams. Different constraints may apply on an environment basis and may even have access to different infrastructure. 

**CI-CD Pipelines**

The CI-CD pipeline is used to track code promotion and build automation/testing across multiple environments. DevOps teams usually work across environments and require a single plane to track progress of code changes and testing across multiple environments in an enterprise.

**Budgets**

Budgets are an important component of self-service, since admins need to track usage of infrastructure across users and teams in the enterprise. With hybrid cloud becoming the norm, IT must be able to normalize and track usage across both public and private clouds in $ terms. Introducing usage tracking and accountability via budgets also ensures that teams use infrastructure judiciously, returning resources back to IT once they are no longer in use rather than hoarding infrastructure. 

**Policy Engine**

The policy engine was born from the realization that business rules and infrastructure rules should not be mixed. Traditional automation bakes in business rules into each automation process and script. However, this means that any single change in business rules requires changes to multiple scripts that reference that particular process. For this reason, the policy engine is a separate layer that constrains what actions can be performed on infrastructure, enabling IT to maintain oversight while still enabling self-service and automation.

**Competition**

Calm is an opinionated and UX-first automation layer that enables NTNX customers to manage their federated infrastructure. 

NTNX competition in the automation and orchestration plane is NOT VMware vRA. As we launch Xi and bring Calm to Prism on-prem and the Xi control plane, the competition will be AWS foremost, with the possibility of smaller startups out-innovating NTNX as a company. This is why Calm is not be benchmarked to vRA features, though NTNX will prioritize features as per customer requirements for the Entery.


Key Terms
*********

Brief definition of key terms used in document. 

**Infrastructure**

Infrastructure is plain-jane infrastructure comprised of IaaS, consisting of Compute, Network & Storage. Infrastructure is 
dumb and does not understand the applications running on top of it. Infrastructure can be provided by multiple Providers. 
Some of these providers are in-house captive, some are pay-as-you-go utility providers. Irrespective of origin all 
infrastructure costs real dollars to run per unit-of-time. Some infrastructure comes with (practically) infinite capacity 
vs others have hard limits. A good analogy is energy consumption from Electricity companies vs having on-prem Diesel 
Generators. Examples are AWS, vCenter, Azure.

**Service**

A component of the application e.g. a VM.

**Action**

Application or service-level workflow.

- “Create” action will deploy the application.
- “Delete” action will … ?  Yes, reverse the “Create” action and delete VMs.

**Projects**

Used for access control and RBAC.

**Settings**

- Cloud connectors.
- Enable/disable Marketplace.


**Blueprints**

Blueprints are App Recipes. These recipes encompass App Architecture, Infrastructure choices, Provisioning & Deployment steps, App Bits, Command steps, Monitoring endpoints, Remediation steps, Licensing & Monetization, Policies. Every time a Blueprint is executed it gives rise to an App.

.. figure:: http://s3.nutanixworkshops.com/calm/nucalm/image8.png

**App**

App is a deployed Blueprint. Every time a Blueprint runs it creates a new App instance. Apps have their own life cycle. 

Also could be considered as a collection of 1 or more VMs managed by Calm.

E.g. a typical dynamic website.

- Web Server (NGINX/Apache/IIS).
- Database server (MariaDB/MySQL/MSSQL).


An App has the following life cycle steps:

1. Instantiation: A blueprint is instantiated to setup the application. Instantiation is 

   i. Provision the Infrastructure components (compute, storage, network)

   ii.	Fetch the App Bits
   iii.	Deploy & Configure the App Bits on infrastructure components
   iv.	Run the Sanity Checks

2. Running: After instantiation, the App is up and running. In running stage the application needs periodic Command steps to keep it healthy and operational. These include upgrades, scale-up, scale-down, start, stop, backup (i.e. common App specific actions defined in the blueprint).

3. Destruction: At a certain point the instantiated App is no longer useful. A destruction (or delete) operation undoes all the creation steps, makes sure all the tied up resources (Infrastructure) is returned to the common pool


**Blueprint Components**

The visual design & content of your application.  Where all application specs are laid out.

Important components:

1. App Architecture: 

App architecture specifies how the different components in the target App are connected. This comprises of nodes of different types (compute, storage, network) and the connections between them.

2. Infrastructure choices: 

Any useful blueprint needs Infrastructure for instantiation. A blueprint can specify the exact infrastructure needed (n AWS VM, m Nutanix VM), a predefined palette or can be completely left to user to specify at instantiation time (late binding). The blueprint developer can also specify policies (or constraints) on the type of infrastructure needed. The platform will not let a blueprint be instantiated if the policies are not met. Other additional policies can be overlaid on the blueprint specified ones later, depending on the organisation setup.

3. Provisioning steps: 

Provisioning is the action of creating infrastructure components (VMs, Firewalls, Containers, Storage,...). Provisioning is usually performed by calling out the Provider specific APIs or commands.

4. App Bits: 

App Bits are the actual software needed for the application to run. A blueprint should have URIs pointing to repositories from where the actual bits are fetched. A blueprint should not bundle the application bits, for size & IP concerns.

5. Deployment steps: 

Deployment steps are the commands/scripts needed to setup the App bits to run on the provisioned infrastructure. These are the steps run on each node of infrastructure to setup the node-specific software. Since some of these nodes are virtual endpoints (S3 buckets) these steps can also be specified in terms of API operations that virtual endpoint supports.

6. Command Steps: 

Command steps are common actions needed to maintain an application. Some of these steps run only on one node in the application while others are multi-node orchestrated flows. Examples include: upgrade, scale-up, scale-down, backup, restore, start, stop. Most of these Commands are specified by the Blueprint developer but the end consumer (with appropriate permissions) should be able to add more to simplify their common use-cases.

7. Monitoring Endpoints: 

A blueprint optionally includes the steps needed to configure common monitoring solutions to setup monitoring for the newly deployed App. The blueprint specifies health checks and metrics along with warning & error thresholds for each node. In addition the blueprint specifies endpoints into the Calm platform where monitoring should feed alerts and other data.

8. Remediation steps: 

Remediation steps are needed to get the App to a healthy stage after monitoring or Calm detects runtime errors or alerts. They are triggered by data from the underlying platform or monitoring endpoints.

9. Licensing & Monetization: 

A blueprint needs to include machine-readable bits on its licensing restrictions. This informs Calm if the blueprint is editable or shareable by the consumer. Calm can hide the actual scripts from the consumer if  so specified. Monetization decides if the blueprint publisher charges a cost for using it. See Chargeback.

10. Policies: 

Policies are requirements for other different components for a blueprint. Policies specify what meta-objectives have to be met for a successful instantiation and use. For example, a policy can specify that the desired App can be instantiated on on-prem Infrastructure, or that a specific node type always requires more than 4 GB RAM.


**Marketplace**

Marketplace is the exchange channel between blueprint publishers and consumers. Publishers upload or publish their blueprints to the Marketplace to make it available for Consumers. Consumers search/browse the Marketplace to find desired Blueprints and then (depending on other considerations) download and use them.

- Marketplace is ONLY for deployment automation and ease of use.
- BYOL: Customers need to input their own existing licenses into the apps.
- NTNX is NOT taking software business from channel.

Key Actors / Dramatis Persona
*****************************

1.	Publisher / Producer: The publisher is responsible for developing Blueprints. 

2.	Consumer / Customer: The consumer uses the Blueprints to deploy and manage desired Apps. 

3.	Infrastructure Admin (Admin): The Infrastructure Admin is responsible for buying, setting up and maintaining the IaaS. This includes one or more people in the IT group that maintain and run the Infrastructure Platforms. Examples are the vCenter Admin team, the Xi Admin team, The inhouse AWS Admin team.

4.	IT Admin (DevOps): The IT Admin manages Apps deployed on the Infrastructure (in contrast to Infrastructure Admins that manage the pure Infrastructure). The IT Admins also set organization IT policies to meet business goals.

5.	OOB Users: These are users who do not exist in the system but are needed for approvals, notifications


Marketplace
***********

In designing the NTNX App Store we have two main choices, with different mix-n-match possibilites:

1.	Vertically Integrated / Walled Garden Only Nutanix (and carefully vetted partners) are allowed to publish Blueprints (heavy regulation).

2.	Two-sided Open Market Third party publishers (ISV ) can publish Blueprints, subject to meeting objective criteria (lightweight regulation).

Two sided markets are notoriously hard to bootstrap. The usual approach is to create a high quality walled garden to build a customer base and then getting more third party producers in. This avoids the chicken and egg problem of bringing of both producers and consumers onboard at the same time.

We have an additional wrinkle in that Calm can be deployed in a completely isolated on-prem installations where the users might want to publish Blueprints for internal consumption. 

.. figure:: http://s3.nutanixworkshops.com/calm/nucalm/image1.png

Functions of a Marketplace
**************************

**Discovery**

A Marketplace allows consumers to discover needed services. In our case customers should be able to search by various criteria and recommendations to find blueprints they are interested in.

**Reputation Metrics**

Marketplace keeps track of reputation, ratings & feedback of both producers and consumers. This greatly aids Discovery. 

**Transaction Guarantees**

Marketplace provides transaction guarantees to producers and consumers when they enter into an exchange (when Blueprints are consumed or updated). If we allow monetization this guarantees the producer gets paid (in whatever virtual currency). 

**Enforceable Property Rights**

Marketplace provides platform enforced intellectual property rights. This includes controls over if a Blueprint is shareable, editable, internals visible. Producers desire these guarantees for their IP.

**Support Forums**

Support forums provide a channel for the producers and consumers to interact outside of the produce-consume cycle. This helps in building communities and feeds into the reputation metrics.

**Costing and Chargeback / Monetization**

Marketplace lets consumers see the costs associated with a Blueprint, including upfront costs and ongoing running costs.

**Curation and Approvals**

Marketplace provides curation and approvals for consuming blueprints, enforced by the competent authorities. The competent authorities here include: Marketplace owners (Nutanix & on-prem admin), IT Admins & Platform Admins.


Publishers
**********

Publishers produce the Blueprints for use by Consumers. 

**Publisher personas**

1.	Nutanix team
2.	Customer IT-Ops/DevOps team
3.	Customer Developers (for inhouse apps)
4.	Third Parties (ISV)

**Publisher Incentives**

Publishers have various overlapping incentives to build Blueprints.

1.	Enable Self Service for consumers within organization to reduce workload
2.	Promote ease-of-use of the platform (probably only true for Nutanix team)
3.	Get paid for know-how in Blueprint
4.	Social Standing

**Publisher Concerns**

1.	Loss of control over usage
2.	Intellectual property leakage
3.	Security / Secret Sauce leakage

**Publisher Workflow**

.. figure:: http://s3.nutanixworkshops.com/calm/nucalm/image2.png

**Publisher Friction**

We need to make publishing as frictionless as possible. This will need:

1.	Simplified and human writable Blueprint code
2.	Complete command line tooling
3.	Offline development (without connecting to central server or running full Calm server)
4.	Lightweight and fast
5.	Integration into modern development workflows (Version Control, Code Reviews, Smoke Tests)

**Consumers**

Consumers use the published blueprints to deploy and manage Apps.

Consumer Workflow:

.. figure:: http://s3.nutanixworkshops.com/calm/nucalm/image3.png


.. |image0| image:: nucalm/media/image1.png
.. |image1| image:: nucalm/media/image2.png
.. |image2| image:: nucalm/media/image3.png
.. |image3| image:: nucalm/media/image10.png
.. |image4| image:: nucalm/media/image8.png
.. |image5| image:: nucalm/media/image9.png
.. |image6| image:: nucalm/media/image16.png
.. |image7| image:: nucalm/media/image18.png
.. |image8| image:: nucalm/media/image19.png


