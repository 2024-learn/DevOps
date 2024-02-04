# Automating with Python

- python packages for clouds:
  - AWS: <https://pypi.org/project/boto3/>
    - `pip install boto3`
  - Google Cloud: <https://pypi.org/project/google-cloud/>
  - Azure: <https://pypi.org/project/azure/>

- named parameters
  - pass arguments via key-value.
  - also called "keyword arguments"
  - this way the order of the parameters does not matter

- client vs resource
  - client: more low-level API
    - provides one to one mapping to underlying HTTP API operations
  - resource: provides resource objects to access attributes and perform actions
    - it is basically a wrapper around the client that makes a bit easier to work with different resources.
    - high level and object oriented
    - resource returns a resource object that we can use to make subsequent calls

- scheduling tasks
  - use schedule library: <https://pypi.org/project/schedule/>
  - `pip install schedule`

- with statement
  - alternative to try/finally statements
  - is used in exception hadling and cleanup code to make code cleaner
  - used with unmanaged resources (e.g. file handling)

- without two-way verification:
  - provide email and password in python code
  - <https://myaccount.google.com/lesssecureapps>
  - generate an app password if you have 2-step auth
  - set it in the code with environment vars, using `import os` module
    - os module provides OS dependent functionality
  - on Pycharm: click file: edit configurations > enviroment variables > add EMAIL_PASSWORD(key) and value, and EMAIL_PASSWORD(value) or set it in ~/.bash_profile
  - smtp.sendmail(sender email address, receiver email address, message)

- exception: when python script encounters a situation that it cannot cope with, it raises(or throws) an exception
  - use try/except in such cases
  - Exception is a python object that represents an error

- Paramiko:<https://pypi.org/project/paramiko/>
  - Python implementation of SSHv2
  - library for making SSH connections (client or server)
  - `pip install paramiko`
  -
