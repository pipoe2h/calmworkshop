**********************
Setup CentOS Server v7
**********************


Introduction
************

When you first create a new server, there are a few configuration steps that you should take early on as part of the basic setup. This will increase the security and usability of your server and will give you a solid foundation for subsequent actions.

Step 1 - Root Login
*******************

To log into your server, you will need to know your server's public IP address and the password for the "root" user's account. If you have not already logged into your server, you may want to follow the first tutorial in this series, How to Connect to Your Droplet with SSH, which covers this process in detail.

If you are not already connected to your server, go ahead and log in as the root user using the following command (substitute the highlighted word with your server's public IP address):

.. code-block:: bash

  $ ssh root@SERVER_IP_ADDRESS

Complete the login process by accepting the warning about host authenticity, if it appears, then providing your root authentication (password or private key). If it is your first time logging into the server, with a password, you will also be prompted to change the root password.

**About Root**

The root user is the administrative user in a Linux environment that has very broad privileges. Because of the heightened privileges of the root account, you are actually discouraged from using it on a regular basis. This is because part of the power inherent with the root account is the ability to make very destructive changes, even by accident.

The next step is to set up an alternative user account with a reduced scope of influence for day-to-day work. We'll teach you how to gain increased privileges during the times when you need them.

Step 2 - Create a New User
**************************

Once you are logged in as root, we're prepared to add the new user account that we will use to log in from now on.

This example creates a new user called "demo", but you should replace it with a user name that you like:

.. code-block:: bash

  $ adduser nucalm

Next, assign a password to the new user (again, substitute "nucalm" with the user that you just created):

.. code-block:: bash

  $ passwd nucalm

Enter a password, and repeat it again to verify it.

Step 3 - Root Privileges
************************

Now, we have a new user account with regular account privileges. However, we may sometimes need to do administrative tasks. To avoid having to log out of our normal user and log back in as the root account, we can set up what is known as "super user" or root privileges for our normal account. This will allow our normal user to run commands with administrative privileges by putting the word sudo before each command.
To add these privileges to our new user, we need to add the new user to the "wheel" group. By default, on CentOS 7, users who belong to the "wheel" group are allowed to use the sudo command.
As root, run this command to add your new user to the wheel group (substitute the highlighted word with your new user):

.. code-block:: bash

  $ gpasswd -a nucalm wheel

Now your user can run commands with super user privileges! For more information about how this works, check out our sudoers tutorial.

Step 4 (Optional) — Configure SSH Daemon
*****************************

Now that we have our new account, we can secure our server a little bit by modifying its SSH daemon configuration (the program that allows us to log in remotely) to disallow remote SSH access to the root account.

Begin by opening the configuration file with your text editor as root:

.. code-block:: bash

  $ vi /etc/ssh/sshd_config

Here, we have the option to disable root login through SSH. This is generally a more secure setting since we can now access our server through our normal user account and escalate privileges when necessary.

To disable remote root logins, we need to find the line that looks like this:

/etc/ssh/sshd_config (before)

.. code-block:: bash

  #PermitRootLogin yes

Hint: To search for this line, type /PermitRoot then hit ENTER. This should bring the cursor to the "P" character on that line.

Uncomment the line by deleting the "#" symbol (press Shift-x).

Now move the cursor to the "yes" by pressing c.

Now replace "yes" by pressing cw, then typing in "no". Hit Escape when you are done editing. It should look like this:

.. code-block:: bash

  /etc/ssh/sshd_config (after)
  PermitRootLogin no

Disabling remote root login is highly recommended on every server!

Enter :x then ENTER to save and exit the file.

**Reload SSH**

Now that we have made our changes, we need to restart the SSH service so that it will use our new configuration.

Type this to restart SSH:

.. code-block:: bash

  $ systemctl reload sshd

Now, before we log out of the server, we should test our new configuration. We do not want to disconnect until we can confirm that new connections can be established successfully.

Open a new terminal window. In the new window, we need to begin a new connection to our server. This time, instead of using the root account, we want to use the new account that we created.

For the server that we configured above, connect using this command. Substitute your own information where it is appropriate:

.. code-block:: bash

  $ ssh nucalm@SERVER_IP_ADDRESS

**Note:** If you are using PuTTY to connect to your servers, be sure to update the session's port number to match your server's current configuration.

You will be prompted for the new user's password that you configured. After that, you will be logged in as your new user.

Remember, if you need to run a command with root privileges, type "sudo" before it like this:

.. code-block:: bash

  $ sudo command_to_run

If all is well, you can exit your sessions by typing:

.. code-block:: bash

  $ exit

At this point, you have a solid foundation for your server. You can install any of the software you need on your server now.

