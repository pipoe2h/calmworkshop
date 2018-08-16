***********************
SSH Password-less Login
***********************


Introducton
***********

SSH is a client and server protocol, and it helps us to access the remote system over the network through the encrypted tunnel. Whenever the client access the server, the client downloads the secure key from the server and at the same time-server also downloads the key from a client. Those two keys make the encrypted tunnel between the server and client, so that data transfer very securely over the network.
SSH is widely used as the alternative to FTP, as you know any thing that uses TCP network asks password to collect data. SSH is also a TCP service, and it requires a password to access the remote machine. If the organization has a large number of servers, every time admin has to enter the password to access the remote system. It is a pain to enter the password multiple times; SSH comes with new feature called password less login, that helps to access the remote machine without entering the password.
To enable the password less login, we have to put the public key entry of client host name and user detail on the remote server. That key entry will be on the following file (~/.ssh/authorized_keys) (~=Home directory of the user) according to your remote user.
Follow the steps to create the password less login. Here we have two machines with two different usernames

**Assumptions:**

1. We'll assume you've successfully deployed the MySQL Application and is currently running.
2. You've successfully created a CentOS Server v7 VM  to host *Ansible*.

Step 1: Create remote users
****************************

Create/Add a new user *ansible*, on each of the CentOS v7 servers used for Web and DB.

.. code-block:: bash

  $ adduser ansible
  $ passwd ansible
  Changing password for user test.
  New password:   (type: P@$$w0rd)
  Retype new password: (type: P@$$w0rd)
  passwd: all authentication tokens updated successfully
  $


Step 2: Create SSH KEY
**********************

- Login to CentOS Server v7 VM hosting *Ansible* as user: *nucalm*.
- Create a pair of keys using the *ssh-keygen* command:

.. code-block:: bash

  $ ssh-keygen
  Generating public/private rsa key pair.
  Enter file in which to save the key (/home/nucalm/.ssh/id_rsa):      **Press Enter**
  Created directory '/home/test/.ssh'.
  Enter passphrase (empty for no passphrase):                          **Press Enter**
  Enter same passphrase again:                                         **Press Enter**
  Your identification has been saved in /home/test/.ssh/id_rsa.
  Your public key has been saved in /home/test/.ssh/id_rsa.pub.
  The key fingerprint is:
  f0:00:a0:12:6f:27:1b:2e:38:a2:4b:37:d8:65:5c:36 test@CentOS.localdomain
  The key's randomart image is:
  +--[ RSA 2048]----+
  |. ...            |
  | +   .           |
  |o = . oE         |
  |oo =. o+.        |
  |= o  +  S        |
  |ooo o            |
  |.o +             |
  |... .            |
  |.                |
  +-----------------+

  $



Step 3: Migrate SSH KEY
***********************

Once you have sucessfully created the keys, you will find two files inside you *.ssh* directory: *id_rsa* and *id_rsa.pub*. We are going to use *id_rsa.pub* as a base file.

.. code-block:: bash

  $ ll ~/.ssh/
  total 8
  -rw-------. 1 test test 1679 Dec 10 09:51 id_rsa
  -rw-r--r--. 1 test test  405 Dec 10 09:51 id_rsa.pub

Use the *ssh-copy-id* command with an input file of *id_rsa.pub*; it creates ~/.ssh/authorized_keys if not present, otherwise it would replace the key.

**Note:** The key contains the information about *nucalm* host and user name.

Copy the new keys from the *Ansible* host to each host participating in the MySQL Application (i.e. *MySQLMaster, MySQLSlave*) using the ansible user created earlier in Step 1.

.. code-block:: bash

  $ ssh-copy-id -i ~/.ssh/id_rsa.pub ansible@remote-machine-ipaddress

and

.. code-block:: bash

  $ ssh-copy-id -i ~/.ssh/id_rsa.pub root@remote-machine-ipaddress

Test your password-less logins using *ssh* to login to each of the hosts participating in the MySQL Application.

.. code-block:: bash

  $ ssh ansible@[IP ADDRESS]
  Last login: Sun Dec 10 09:24:56 2017 from 10.21.9.85
  $

.. note:: You should **NOT** be prompted for a password...
