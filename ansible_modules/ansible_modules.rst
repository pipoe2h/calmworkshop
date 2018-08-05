****************************
Developing an Ansible module
****************************

Introduction
************
Ansible is a great tool to automate almost everything in an IT environment. One of the huge benefits of Ansible are the so called modules: they provide a way to address automation tasks in the native language of the problem. For example, given a user needs to be created: this is usually done by calling certain commandos on the shell. In that case the automation developer has to think about which command line tool needs to be used, which parameters and options need to be provided, and the result is most likely not idempotent. And its hard t run tests (“checks”) with such an approach.
Enter Ansible user modules: with them the automation developer only has to provide the data needed for the actual problem like the user name, group name, etc. There is no need to remember the user management tool of the target platform or to look up parameters:

.. code-block:: bash

  $ ansible server -m user -a "name=abc group=wheel" -b

Ansible comes along with hundreds of modules. But what is if your favorite task or tool is not supported by any module? You have to write your own Ansible module. If your tools support REST API, there are a few things to know which makes it much easier to get your module running fine with Ansible. These few things are outlined below.

REST APIs and Python libraries in Ansible modules
*************************************************

According to Wikipedia, REST is:

  *"...the software architectural style of the World Wide Web."*

In short, its a way to write, provide and access an API via usual HTTP tools and libraries (Apache web server, Curl, you name it), and it is very common in everything related to the WWW.
To access a REST API via an Ansible module, there are a few things to note. Ansible modules are usually written in Python. The library of choice to access URLs and thus REST APIs in Python is usually urllib. However, the library is not the easiest to use and there are some security topics to keep in mind when these are used. Out of these reasons alternative libraries like Python requests came up in the past and are pretty common.
However, using an external library in an Ansible module would add an extra dependency, thus the Ansible developers added their own library inside Ansible to access URLs: ansible.module_utils.urls. This one is already shipped with Ansible – the code can be found at lib/ansible/module_utils/urls.py – and it covers the shortcomings and security concerns of urllib. If you submit a module to Ansible calling REST APIs the Ansible developers usually require that you use the inbuilt library.
Unfortunately, currently the documentation on the Ansible url library is sparse at best. If you need information about it, look at other modules like the Github, Kubernetes or a10 modules. To cover that documentation gap I will try to cover the most important basics in the following lines – at least as far as I know.

Creating REST calls in an Ansible module
****************************************

To access the Ansible urls library right in your modules, it needs to be imported in the same way as the basic library is imported in the module:

.. code-block:: python

  from ansible.module_utils.basic import *
  from ansible.module_utils.urls import *

The main function call to access a URL via this library is open_url. It can take multiple parameters:

.. code-block:: python

  def open_url(url, data=None, headers=None, method=None, use_proxy=True,
        force=False, last_mod_time=None, timeout=10, validate_certs=True,
        url_username=None, url_password=None, http_agent=None,
        force_basic_auth=False, follow_redirects='urllib2'):

**The parameters in detail are:**

**url:** the actual URL, the communication endpoint of your REST API

**data:** the payload for the URL request, for example a JSON structure

**headers:** additional headers, often this includes the content-type of the data stream

**method:** a URL call can be of various methods: GET, DELETE, PUT, etc.

**use_proxy:** if a proxy is to be used or not

**force:** force an update even if a 304 indicates that nothing has changed (I think…)

**last_mod_time:** the time stamp to add to the header in case we get a 304

**timeout:** set a timeout

**validate_certs:** if certificates should be validated or not; important for test setups where you have self signed certificates

**url_username:** the user name to authenticate

**url_password:** the password for the above listed username

**http_agent:** if you wnat to set the http agent

**force_basic_auth:** for ce the usage of the basic authentication

**follow_redirects:** determine how redirects are handled

For example, to fire a simple GET to a given source like Google most parameters are not needed and it would look like:

.. code-block:: python

  open_url('https://www.google.com',method="GET")

A more sophisticated example is to push actual information to a REST API. For example, if you want to search for the domain example on a Satellite server you need to change the method to PUT, add a data structure to set the actual search string ({"search":"example"}) and add a corresponding content type as header information ({'Content-Type':'application/json'}). Also, a username and password must be provided. Given we access a test system here the certification validation needs to be turned off also. The resulting string looks like this:

.. code-block:: python
  open_url('https://satellite-server.example.com/api/v2/domains',method="PUT",url_username="admin",url_password="abcd",data=json.dumps({"search":"example"}),force_basic_auth=True,validate_certs=False,headers={'Content-Type':'application/json'})

Beware that the data json structure needs to be processed by json.dumps. The result of the query can be formatted as json and further used as a json structure:

.. code-block:: python
  
  resp = open_url(...)
  resp_json = json.loads(resp.read())

Full example

In the following example, we query a Satellite server to find a so called environment ID for two given parameters, an organization ID and an environment name. To create a REST call for this task in a module multiple, separate steps have to be done: first, create the actual URL endpoint. This usually consists of the server name as a variable and the API endpoint as the flexible part which is different in each REST call.

.. code-block:: python

  server_name = 'https://satellite.example.com'
  api_endpoint = '/katello/api/v2/environments/'
  my_url = server_name + api_endpoint

Besides the actual URL, the payload must be pieced together and the headers need to be set according to the content type of the payload – here json:

.. code-block:: python

  headers = {'Content-Type':'application/json'}
  payload = {"organization_id":orga_id,"name":env_name}

Other content types depends on the REST API itself and on what the developer prefers. JSON is widely accepted as a good way to go for REST calls.

Next, we set the user and password and launch the call. The return data from the call are saved in a variable to analyze later on.

.. code-block:: python

  user = 'abc'
  pwd = 'def'
  resp = open_url(url_action,method="GET",headers=headers,url_username=module.params.get('user'),url_password=module.params.get('pwd'),force_basic_auth=True,data=json.dumps(payload))

Last but not least we transform the return value into a json construct, and analyze it: if the return value does not contain any data – that means the value for the key total is zero – we want the module to exit with an error. Something went wrong, and the automation administrator needs to know that. The module calls the built-in error functionmodule.fail_json. But if the total is not zero, we get out the actual environment ID we were looking for with this REST call from the beginning – it is deeply hidden in the json structure, btw.

.. code-block:: python

  resp_json = json.loads(resp.read())
  if resp_json["total"] == 0:
      module.fail_json(msg="Environment %s not found." % env_name)
  env_id = resp_json["results"][0]["id"]

Summary
*******

It is fairly easy to write Ansible modules to access REST APIs. The most important part to know is that an internal, Ansible provided library should be used, instead of the better known urllib or requests library. Also, the actual library documentation is still pretty limited, but that gap is partially filled by the above possible.
