******
DevOps
******


Introduction
************

DevOps is the combination of cultural philosophies, practices, and tools that increases an organization’s ability to deliver
applications and services at high velocity: evolving and improving products at a faster pace than organizations using
traditional software development and infrastructure management processes. This speed enables organizations to better serve
their customers and compete more effectively in the market.

.. figure:: http://s3.nutanixworkshops.com/calm/devops/image3.png

Under a DevOps model, development and operations teams are no longer “siloed.” Sometimes, these two teams are merged into a
single team where the engineers work across the entire application lifecycle, from development and test to deployment to
operations, and develop a range of skills not limited to a single function. Quality assurance and security teams may also
become more tightly integrated with development and operations and throughout the application lifecycle.

.. figure:: http://s3.nutanixworkshops.com/calm/devops/image4.png

These teams use practices to automate processes that historically have been manual and slow. They use a technology
stack and tooling which help them operate and evolve applications quickly and reliably. These tools also help engineers
independently accomplish tasks (for example, deploying code or provisioning infrastructure) that normally would have 
required help from other teams, and this further increases a team’s velocity.

Benefits of DevOps
******************

**Speed**

Move at high velocity so you can innovate for customers faster, adapt to changing markets better, and grow more efficient
at driving business results. The DevOps model enables your developers and operations teams to achieve these results. For 
example, microservices and continuous delivery let teams take ownership of services and then release updates to them quicker.

**Rapid Delivery**

Increase the frequency and pace of releases so you can innovate and improve your product faster. The quicker you can release 
new features and fix bugs, the faster you can respond to your customers’ needs and build competitive advantage. Continuous 
integration and continuous delivery are practices that automate the software release process, from build to deploy.

**Reliability**

Ensure the quality of application updates and infrastructure changes so you can reliably deliver at a more rapid pace while 
maintaining a positive experience for end users. Use practices like continuous integration and continuous delivery to test 
that each change is functional and safe. Monitoring and logging practices help you stay informed of performance in real-time.

**Scale**

Operate and manage your infrastructure and development processes at scale. Automation and consistency help you manage complex
or changing systems efficiently and with reduced risk. For example, infrastructure as code helps you manage your development, 
testing, and production environments in a repeatable and more efficient manner.

**Improved Collaboration**

Build more effective teams under a DevOps cultural model, which emphasizes values such as ownership and accountability. 
Developers and operations teams collaborate closely, share many responsibilities, and combine their workflows. This reduces 
inefficiencies and saves time (e.g. reduced handover periods between developers and operations, writing code that takes 
into account the environment in which it is run).

**Security**

Move quickly while retaining control and preserving compliance. You can adopt a DevOps model without sacrificing security by
using automated compliance policies, fine-grained controls, and configuration management techniques. For example, using 
infrastructure as code and policy as code, you can define and then track compliance at scale.

DevOps Practices
****************

There are a few key practices that help organizations innovate faster through automating and streamlining the software
development and infrastructure management processes. Most of these practices are accomplished with proper tooling.

.. figure:: http://s3.nutanixworkshops.com/calm/devops/image1.png

One fundamental practice is to perform very frequent but small updates. This is how organizations innovate faster for
their customers. These updates are usually more incremental in nature than the occasional updates performed under traditional 
release practices. Frequent but small updates make each deployment less risky. They help teams address bugs faster because 
teams can identify the last deployment that caused the error. Although the cadence and size of updates will vary, 
organizations using a DevOps model deploy updates much more often than organizations using traditional software development 
practices.

Organizations might also use a microservices architecture to make their applications more flexible and enable quicker 
innovation. The microservices architecture decouples large, complex systems into simple, independent projects. Applications 
are broken into many individual components (services) with each service scoped to a single purpose or function and operated 
independently of its peer services and the application as a whole. This architecture reduces the coordination overhead of 
updating applications, and when each service is paired with small, agile teams who take ownership of each service, 
organizations can move more quickly.

However, the combination of microservices and increased release frequency leads to significantly more deployments which can 
present operational challenges. Thus, DevOps practices like continuous integration and continuous delivery solve these issues 
and let organizations deliver rapidly in a safe and reliable manner. Infrastructure automation practices, like infrastructure 
as code and configuration management, help to keep computing resources elastic and responsive to frequent changes. 
In addition, the use of monitoring and logging helps engineers track the performance of applications and infrastructure so 
they can react quickly to problems.

Together, these practices help organizations deliver faster, more reliable updates to their customers. Here is an overview 
of important DevOps practices.

**Continuous Integration**

Continuous integration is a software development practice where developers regularly merge their code changes into a central
repository, after which automated builds and tests are run. The key goals of continuous integration are to find and address
bugs quicker, improve software quality, and reduce the time it takes to validate and release new software updates.

**Continuous Deliver**

Continuous delivery is a software development practice where code changes are automatically built, tested, and prepared for a
release to production. It expands upon continuous integration by deploying all code changes to a testing environment and/or a
production environment after the build stage. When continuous delivery is implemented properly, developers will always have
a deployment-ready build artifact that has passed through a standardized test process.

**Microservices**

The microservices architecture is a design approach to build a single application as a set of small services. Each service 
runs in its own process and communicates with other services through a well-defined interface using a lightweight mechanism, 
typically an HTTP-based application programming interface (API). Microservices are built around business capabilities; each 
service is scoped to a single purpose. You can use different frameworks or programming languages to write microservices and 
deploy them independently, as a single service, or as a group of services.

**Infrastructure as Code**

Infrastructure as code is a practice in which infrastructure is provisioned and managed using code and software development 
techniques, such as version control and continuous integration. The cloud’s API-driven model enables developers and system 
administrators to interact with infrastructure programmatically, and at scale, instead of needing to manually set up and 
configure resources. Thus, engineers can interface with infrastructure using code-based tools and treat infrastructure in 
a manner similar to how they treat application code. Because they are defined by code, infrastructure and servers can quickly 
be deployed using standardized patterns, updated with the latest patches and versions, or duplicated in repeatable ways.

*Configuration Management*

Developers and system administrators use code to automate operating system and host configuration, operational tasks, and
more. The use of code makes configuration changes repeatable and standardized. It frees developers and systems administrators 
from manually configuring operating systems, system applications, or server software.

*Policy as Code*

With infrastructure and its configuration codified with the cloud, organizations can monitor and enforce compliance 
dynamically and at scale. Infrastructure that is described by code can thus be tracked, validated, and reconfigured in an 
automated way. This makes it easier for organizations to govern changes over resources and ensure that security measures 
are properly enforced in a distributed manner (e.g. information security or compliance with PCI-DSS or HIPAA). This allows 
teams within an organization to move at higher velocity since non-compliant resources can be automatically flagged for 
further investigation or even automatically brought back into compliance.


Summary
*******

The DevOps model relies on effective tooling to help teams rapidly and reliably deploy and innovate for their customers. 
These tools automate manual tasks, help teams manage complex environments at scale, and keep engineers in control of the 
high velocity that is enabled by DevOps. AWS provides services that are designed for DevOps and that are built first for 
use with the AWS cloud. These services help you use the DevOps practices described above.


.. |image0| image:: devops/media/image3.png
.. |image1| image:: devops/media/image4.png
.. |image2| image:: devops/media/image1.png




