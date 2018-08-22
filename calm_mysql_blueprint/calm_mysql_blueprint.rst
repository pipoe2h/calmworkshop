.. _calm_mysql_blueprint:

---------------------
Calm: MySQL Blueprint
---------------------

Overview
++++++++

Creating Blueprint (MySQL)
++++++++++++++++++++++++++

In this exercise you will explore the basics of Nutanix Calm by building and deploying a Blueprint that installs and configures a single service, MySQL, on a CentOS image.

Creating Blueprint
..................

From **Prism Central > Apps**, select **Blueprints** from the sidebar and click **+ Create Application Blueprint**.

Specify **CalmIntro<INITIALS>** in the **Blueprint Name** field.
Enter a **Description** in the Description field.
Select **Calm** from the **Project** drop down menu and click **Proceed**.

Click **Proceed** to continue.

Click **Credentials >** :fa:`plus-circle` and fill out the following fields then click **Save**:

- **Credential Name** - CENTOS
- **Username** - root
- **Secret** - Password
- **Password** - nutanix/4u

Click **Back**.

.. note::

  Credentials are unique to each Blueprint.

  Each Blueprint requires a minimum of 1 Credential.

Click **Save** to save your Blueprint.

Setting Variables
.................

Variables allow extensibility of Blueprints, meaning a single Blueprint can be used for multiple purposes and environments depending on the configuration of its variables. Variables can either be static values saved as part of the Blueprint or they can be specified at **Runtime** (when the Blueprint is launched). By default, variables are stored in plaintext and visible in the Configuration Pane. Setting a variable as **Secret** will mask the value and is ideal for variables such as passwords.

Variables can be used in scripts executed against objects using the **@@{variable_name}@@** construct. Calm will expand and replace the variable with the appropriate value before sending to the VM.

In the **Configuration Pane** under **Variable List**, fill out the following fields:

+----------------------+------------------------------------------------------+------------+
| **Variable Name**    | **Value**                                            | **Secret** |
+----------------------+------------------------------------------------------+------------+
| Mysql\_user          | root                                                 |            |
+----------------------+------------------------------------------------------+------------+
| Mysql\_password      | nutanix/4u                                           | X          |
+----------------------+------------------------------------------------------+------------+
| Database\_name       | homestead                                            |            |
+----------------------+------------------------------------------------------+------------+
| App\_git\_link       | https://github.com/ideadevice/quickstart-basic.git   |            |
+----------------------+------------------------------------------------------+------------+

.. figure:: images/mysql1.png

Click **Save**.

Adding DB Service
.................

.. note::

  Application Overview - The pane within the Blueprint Editor used to create and manage Blueprint Layers. Blueprint Layers consist of Services, Actions, and Application Profiles.

In **Application Overview > Services**, click :fa:`plus-circle`.

Note **Service1** appears in the **Workspace** and the **Configuration Pane** reflects the configuration of the selected Service.

Fill out the following fields:

- **Service Name** - MySQL
- **Name** - MySQLAHV

  .. note:: This defines the name of the substrate within Calm. Names can only contain alphanumeric characters, spaces, and underscores.

- **Cloud** - Nutanix
- **OS** - Linux
- **VM Name** - MYSQL-@@{calm_array_index}@@-@@{calm_time}@@
- **Image** - CentOS
- **Device Type** - Disk
- **Device Bus** - SCSI
- Select **Bootable**
- **vCPUs** - 2
- **Cores per vCPU** - 1
- **Memory (GiB)** - 4
- Select :fa:`plus-circle` under **Network Adapters (NICs)**
- **NIC** - Primary
- **Credential** - CENTOS

.. note::

  Ensure selecting the **Credential** is the final selection made before proceeding to the next step, selecting other fields can clear your **Credential** selection.

With the MySQL service icon selected in the workspace window, scroll to the top of the **Configuration Panel**, click **Package**.

Fill out the following fields:

- **Package Name** - MYSQL_PACKAGE
- **Click** - Configure install
- **Click** - + Task
- **Name Task** - Install_sql
- **Type** - Execute
- **Script Type** - Shell
- **Credential** - CENTOS

Copy and paste the following script into the **Script** field:

.. code-block:: bash

  #!/bin/bash
  set -ex

  yum install -y "http://repo.mysql.com/mysql-community-release-el7.rpm"
  yum update -y
  yum install -y mysql-community-server.x86_64

  /bin/systemctl start mysqld

  #Mysql secure installation
  mysql -u root<<-EOF

  UPDATE mysql.user SET Password=PASSWORD('@@{Mysql_password}@@') WHERE User='@@{Mysql_user}@@';
  DELETE FROM mysql.user WHERE User='@@{Mysql_user}@@' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';

  FLUSH PRIVILEGES;
  EOF

  sudo yum install firewalld -y
  sudo service firewalld start
  sudo firewall-cmd --add-service=mysql --permanent
  sudo firewall-cmd --reload

  mysql -u @@{Mysql_user}@@ -p@@{Mysql_password}@@ <<-EOF
  #mysql -u @@{Mysql_user}@@ <<-EOF
  CREATE DATABASE @@{Database_name}@@;
  GRANT ALL PRIVILEGES ON homestead.* TO '@@{Database_name}@@'@'%' identified by 'secret';

  FLUSH PRIVILEGES;
  EOF

.. note::

  You can click the **Pop Out** icon on the script field for a larger window to view/edit scripts.

  Looking at the script you can see the package will install MySQL, configure the credentials and create a database based on the variables specified earlier in the exercise.

Select the MySQL service icon in the workspace window again and scroll to the top of the **Configuration Panel**, click **Package**.

- **Click** - Configure Uninstall
- **Click** - + Task
- **Name Task** - Uninstall_sql
- **Type** - Execute
- **Script Type** - Shell
- **Credential** - CENTOS

Copy and paste the following script into the **Script** field:

.. code-block:: bash

  #!/bin/bash
  echo "Goodbye!"

.. note:: The uninstall script can be used for removing packages, updating network services like DHCP and DNS, removing entries from Active Directory, etc. It is not being used for this simple example.

Click **Save**. You will be prompted with specific errors if there are validation issues such as missing fields or unacceptable characters.

Launching the Blueprint
.......................

From the toolbar at the top of the Blueprint Editor, click **Launch**.

In the **Name of the Application** field, specify a unique name (e.g. CalmMySQL*<INITIALS>*-1).

.. note::

  A single Blueprint can be launched multiple times within the same environment but each instance requires a unique **Application Name** in Calm.

Click **Create**.

You will be taken directly to the **Applications** page to monitor the provisioning of your Blueprint.

Select **Audit > Create** to view the progress of your application. After **MySQLAHV - Check Login** is complete, select **PackageInstallTask** to view the real time output of your installation script.

Note the status changes to **Running** after the Blueprint has been successfully provisioned.

.. figure:: https://s3.amazonaws.com/s3.nutanixworkshops.com/calm/lab1/image25.png

Takeaways
+++++++++

- The Blueprint Editor provides a simple UI for modeling potentially complex applications.
- Blueprints are tied to SSP Projects which can be used to enforce quotas and role based access control.
- Having a Blueprint install and configure binaries means no longer creating specific images for individual applications. Instead the application can be modified through changes to the Blueprint or installation script, both of which can be stored in source code repositories.
- Variables allow another dimension of customizing an application without having to edit the underlying Blueprint.
- Application status can be monitored in real time.
