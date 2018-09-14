.. _calm_sshkey_creation:

----------------------
Calm: SSH Key Creation
----------------------

Overview
++++++++

In this exercise you will create SSH private and public keys to be used with Calm.  These keys will be required for any pre-seeded Marketplace appplication, as the default Cloud CentOS image does not allow password based authentication.  They are also required for any of the public clouds.

The methods to generate the SSH keys are different depending on if you're running MacOS / Linux, or Windows.  Please jump to the appropriate section.

MacOS / Linux
+++++++++++++

SSH Key Creation
................

Open up your terminal of choice, and type in *ssh-keygen -t rsa -f ~/[KEY_FILENAME] -C [USERNAME]*.  After hitting enter, follow the prompts.  Note: Using a passphrase on your key is **only** supported if your Prism Central version is greater than or equal to 5.8.1, otherwise a passphrase **cannot** be used.  The below example will not use a passphrase as this will work on all Prism Central versions.

.. code-block:: bash

   $ ssh-keygen -t rsa -f ~/calmkey -C centos@nutanix.com
   Generating public/private rsa key pair.
   Enter passphrase (empty for no passphrase):
   Enter same passphrase again:
   Your identification has been saved in /Users/michael.haigh/calmkey.
   Your public key has been saved in /Users/michael.haigh/calmkey.pub.
   The key fingerprint is:
   SHA256:WFAeoxKbQqFf8qt0F8za9tt3KfXf69LJuESG/N4jy+o centos@nutanix.com
   The key's randomart image is:
   +---[RSA 2048]----+
   |  o.. ..+        |
   | o   + + o       |
   |. o = . o        |
   | . = + o  . .    |
   |  . . = S  o o   |
   |     + .    + .  |
   |  . + +      ++o.|
   | . o o . .  *++=o|
   |  .     o.oE.B*+*|
   +----[SHA256]-----+


Accessing the Private Key
.........................

When working through Calm blueprints and application launches, you'll need the username you provided in the first step (*centos* in my example, as the majority of the pre-seeded marketplace apps use centos as the username), and the contents of the private key (including the **-----BEGIN RSA PRIVATE KEY-----** and **-----END RSA PRIVATE KEY-----** lines, **without** any additional new lines at the end).

.. code-block:: bash

   $ cat calmkey
   -----BEGIN RSA PRIVATE KEY-----
   MIIEowIBAAKCAQEAw6CZT4/gAj8hxptH/hck0D0bfptR+ibLci7bxSVJ7Q8hdv3a
   qXEPUHyisNUHI8xnUkvAeh63Tjoymc+No9Nf2C1hctmKwy0Dh3DSYul6MAkNOfQu
   2x3oT+ZajTem0SM3UJ6hmRmIvIimM1AoTFbrH7D3eWWaNKxwgIggD9chaq3EpqvN
   0DTdV/BWdQjqDAeurysg9qxKHis+JYpRHlisj+ES5pDnNXjGEDXcjDgjRRWypgtZ
   zyfjKcaNR3zUfOEe1jZeaBGjUDjkTfjWjs7uQcYptoYSb1N+yfudOGs2dTwlIh4g
   tPswcOCX3jijL7SJ5pBGUBHd8uEayBy1ygeGGwIDAQABAoIBADINZSx2I1pvzLSE
   Bmd8hG7DM8Ww98iJJISSeKh4YfHFbUqEqO2xf7mYKggUeT8vjUABIb4dHclmGoxA
   Dn1cF6m38rbv8hD982kz9KBaHGkt57RsRZDKliXbSk/XbVcVK5H1BGOnpNSYIe3/
   FFBz7LSvEqJ83Hedpys7qPhkkqg4WsgRZrrQNgkA4WOSm8wSnTHrZnI7VHY/MpYI
   606nKx39O1cjN0tiiXKnasgqKZWDfOO7NvhD+YXPnky2XT+mWoPFmDEx8jrbHt7Q
   DTs7xFpC6TYfQPh7lyhsQDcEYjWZn/ZdEKOhCeo24REbez+tz4s2dL3EyGKbQKkz
   FltVMAECgYEA8IGp5e8zJBhwWq/N7bM5NutUZn9SsEQ039KUTzGUmeE4nnt+0iFf
   t4Uor1/Hzj1PrYqgJl9tHhAXQslYH/l6W7X+u49TJAl5SuESfrH3x5+V95lC5nI4
   SEai7PjmTRZ45jc0tCKnxOgQnCcS6qHgyxWxItr3ps7aMCHrmaBTjCsCgYEA0DrO
   YdRxWCFZOrmwP0xfbPKbuv2sjV6MN+SeDFAl4MV+DYMIF0xgESakLWybisaYytwH
   IRANEDAEuXMUblCJic+a35FC14IlzU3ksZVf83zyleKB15iEgDkI7EoyczumlKiD
   sumBoCBALWzwxNd1tiDm9LyHjnpx2+y640VfxdECgYAPleeDrg+bXDYTumbW65Fe
   nLt4dPHP2GuwwX248BaYLj80Df628VC5nNh5HPTeyZxbO6uLMQ3qL9LCEjgywkEK
   pm2ei/gwUqjYkGNZcIEFH7NhOz5ZnrdE/8bZInwSLM2i5Zr1vXUvznYdGG8iY2Ek
   5//1qUj5N1huXBRffUNMxwKBgELQq8p+ZYQ25y/Nx3z4H6KQ0mGU5lpSXUHODNy8
   lvrhxAnH4r+/FRBLyuB8egh0ozBsm6kDQn3QOqPbBlJDa26Z/AMC1GTccQ7IkLpe
   yPQTQq/Ph4RLfzC5nGBdioSpPlFzJRcykBJ2ZsFstHElBbNUKWecWw7fwUslUe59
   IzcRAoGBAJsNwacNC6VeojCKcp4aaQhH8vEd8F5cff2qGTMjplhqSyl1eqr7IJ3n
   AajZbsS2UJa35UxpSXzeMoUaQB6EG5e//BG5Br+6n1aOHlERJV7t9/Z4re9g2lIk
   msuEm+VNsXpZQ4lspARV8kqWcNzrhGSfgq1BEHWIHBKp93mMigL4
   -----END RSA PRIVATE KEY-----


Accessing the Public Key
........................

Depending on the cloud that you're deploying onto, the public SSH key will be used in different places.  For AHV launches, there's a **INSTANCE_PUBLIC_KEY** macro that you'll paste the key into, and for GCP there's a **SSH KEYS** section.  You'll want to copy the entire single line of the public key (starting with **ssh-rsa** and ending with the username and domain), without any new lines.

.. code-block:: bash

   $ cat calmkey.pub
   ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDoJlPj+ACPyHGm0f+FyTQPRt+m1H6JstyLtvFJUntDyF2/dqpcQ9QfKKw1QcjzGdSS8B6HrdOOjKZz42j01/YLWFy2YrDLQOHcNJi6XowCQ059C7bHehP5lqNN6bRIzdQnqGZGYi8iKYzUChMVusfsPd5ZZo0rHCAiCAP1yFqrcSmq83QNN1X8FZ1COoMB66vKyD2rEoeKz4lilEeWKyP4RLmkOc1eMYQNdyMOCNFFbKmC1nPJ+Mpxo1HfNR84R7WNl5oEaNQOORN+NaOzu5Bxim2hhJvU37J+504azZ1PCUiHiC0+zBw4JfeOKMvtInmkEZQEd3y4RrIHLXKB4Yb centos@nutanix.com


Windows
+++++++

SSH Key Creation
................

If Putty Keygen is not already present on your machine, first download and install puttygen.exe_.

.. _puttygen.exe: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

- Open up Putty Key Generator
- Create a key by clicking **Generate** and then moving your mouse in the blank section
- Convert the private key to OpenSSH format by selecting **Conversion > Export OpenSSH key**

  .. figure:: images/putty1.png

- On the pop-up, select **Yes** as a passphrase is not required, and not supported for Prism Central versions less than 5.8.1

  .. figure:: images/putty2.png

- Save the key with a name of your choice (I'm using **calmPem.pem** in my example)

  .. figure:: images/putty3.png

Accessing the Private Key
.........................

When working through Calm blueprints and application launches, you'll need the contents of the private key that we just generated.  The easiest thing to do is to open the private key (**calmPem.pem** in this example) with a text editor of your choice, and copy the key, starting with **-----BEGIN RSA PRIVATE KEY-----** and ending with **-----END RSA PRIVATE KEY-----** lines, **without** any additional new lines at the end.

.. figure:: images/privatekey.png

Accessing the Public Key
........................

Back in Putty Keygen, near the top there's a Public key section.  Copy the contents of that key, open up a text editor, and save the single line for later use.  Depending on the cloud that you're deploying onto, the public SSH key will be used in different places.  For AHV launches, there's a **INSTANCE_PUBLIC_KEY** macro that you'll paste the key into, and for GCP there's a **SSH KEYS** section.

.. figure:: images/publickey.png

Takeaways
+++++++++

- Calm and the public clouds use private and public RSA SSH Keys for secure authentication
- Private keys are always entered in to the **Credentials** section of the blueprint or application launch page
- Public keys are inputted in different ways depending on the cloud you're deploying onto
