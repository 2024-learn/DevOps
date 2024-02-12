# Ansible

- Why use Ansible?
  - execute tasks from your own machine
  - configuration/installation/deployment steps in a single Yaml file
  - reuse the same file multiple times and for different environments
  - more reliable and lkely for errors
  - Ansible is agentless. So there is no installation effort except on one machine to upgrade to a newer version of ansible or to deploy ansible on the rest of the machines.
    - it connects to the servers using SSH
- Ansible works with modules (small programs that do the actual work).
  - each module is one small specific task
  - module are granula and specific
    - which means that you need multiple modules in a certain sequence grouped together to represent one whole configuration or all the steps to deploy the application
    - modules also called "task plugins" <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html>
- ansible playbooks:
  - each task makes sure the module gets executed with certain arguments and also desribes the task using a name
  - hosts attribute: tells where the tasks should be executed
    - example hosts file:

    ```Hosts File
    10.24.0.100

    [webservers]
    10.24.0.1
    10.24.0.2

    [databases]
    10.24.0.7
    10.24.0.8
    ```

    - the reference is defined in ansible inventory list
      - inventory: all the machines involved in task executions
      - groups multiple IP addresses or host names
  - remote_user: with which user the tasks should be executed
  - vars: variables for repeating values

  ```playbook
  - hosts: databases
    remote_user: root
    vars:
      tablename: foo
      tableowner: someuser
    tasks:
      - name: rename table {{ tablename }} to bar
        postgresql_table:
          table: {{ tablename }}
          rename: {{ bar }}
      - name: set owner to someuser
        postgresql_table:
          name: {{ tablename }}
          owner: someuser
      - name: truncate table
        postgresql_table:
          name: {{ tablename }}
          truncate: yes
  ```

  - "play" defines which tasks and which hosts and which user and some additional outputs
  - a playbook contains multiple plays in a single yaml file which might depend on each other or needs to be executed in the sequence
    - a playbook describes:
      - how and in which order
      - at what time and on which machines
      - whay (the modules) should be executed
    - in other words, it orchestrates the module execution

- Ansible tower: UI dashboard from Red Hat
  - centrally store automation tasks across teams
- install ansible
  - install python. Asnible is dependent on python
  - installing python on Linux: <https://linuxtldr.com/installing-python/>
  - `brew install ansible` or `pip install ansible`
- Ansible inventory file:
  - file containing data about the ansible client servers
  - "hosts" meaning the damaged servers
  - default location: /etc/ansible/hosts
- Ansible ad-hoc commands
  - ad-hoc commands are not stored for future uses but they provide a fast way to interact with the desired servers
  - `ansible [pattern] -m [module] -a "[module options]"`
    - pattern: targeting hosts and groups
      - "all": default group, which contains every host
    - "-i": specifies which host file
    - -m: module
    - `ansible all -i hosts -m ping`
- grouping hosts:
  - you can put each host in more than one group
  - you can create groups that track:
    - WHERE: a datacenter/region, e.g. east, west
    - WHAT: eg. database servers, web servers, etc.
    - WHEN: which stage, e.g. dev, test, prod environment
  - `ansible aws -i hosts -m ping`
  - `ansible 35.182.184.31 -i hosts -m ping`: address a specific machine in a group
  - instead of configuring the same thing over and over, you can define variables

  ```hostfile
  [aws]
  35.182.184.31 ansible_ssh_private_key_file=~/.ssh/formac.pem ansible_user=ubuntu
  15.222.15.60 ansible_ssh_private_key_file=~/.ssh/formac.pem ansible_user=ubuntu
  ```

  ```aws with vars
  [aws]
  35.182.184.31
  15.222.15.60

  [aws:vars]
  ansible_ssh_private_key_file=~/.ssh/formac.pem
  ansible_user=ubuntu
  ```

- you can also use the public dns of the servers

  ```public-dns
  [ec2]
  ec2-15-223-3-159.ca-central-1.compute.amazonaws.com
  ec2-3-99-192-218.ca-central-1.compute.amazonaws.com
  ```

- you can also specify the python interpreter:
  - e.g.:

    ```setting python interpreter
    [ec2]
    ec2-15-223-3-159.ca-central-1.compute.amazonaws.com ansible_python_interpreter=/usr/bin/python3.9
    ec2-3-99-192-218.ca-central-1.compute.amazonaws.com ansible_python_interpreter=/usr/bin/python3.9
    ```

- Host Key Checking:
  - enabled by default in Ansible
  - it guards against server spoofing and man-in-the-middle attacks
  - adding key to known hosts:
    - `ssh-keyscan -H 15.222.15.60 >> ~/.ssh/known_hosts`
    - add local host id_rsa.pub to remote server ~/.ssh/authorized_keys with `ssh-copy-id`
    - ssh ubuntu@15.222.15.60
  - you can also disable key host checking (less secure)
    - usually used on ephemeral servers that are dynamically created and destroyed
    - config file default locations:
      - /etc/ansible/ansible.cfg
      - ~/.ansible.cfg
    - vim ~/.ansible.cfg

      ```~/.ansible.cfg
      [defaults]
      host_key_checking = False
      ```

    - you can also create the .ansible.cfg in the ansible project directory as ansible.cfg(you can create it as a normal file here, not a hidden file)
    .
    ├── ansible.cfg
    ├── hosts
    ├── notes.md
    └── test.yaml
- playbook"
  - ordered list of tasks
  - plays and tasks run in order from top to bottom
  - written in YAML
  - can have multiple plays(a group of tasks that you want to execute on sveral servers)
- executing a playbook:
  - `ansible-playbook -i hosts my-playbook.yaml`
  - alternatively, in the ansible.cfg file yyou can configure the default inventory file with: `inventory = hosts` that way you c an run the command with the -i flag:
    - `ansible-playbook my-playbook.yaml`
- "gather facts" module
  - automatically called by playbooks
  - gathers useful variables about remote hosts that can be used in playbooks
  - so ansible provides may facts about the system, automatically
- idempotency:
  - most modules check whether the desired state has already been achieved
  - they exit without performing any actions if the action has already been achieved
- collection:
  - a packaging format for bundling (playbook, plugins, modules ...etc.) and distributing Ansible content
  - can be released and installed independent of other collections
  - all modules are part of a collection
- plugins:
  - pieces of code that add to ansible's functionality or modules
  - you can also write own plugins
- ansible-galaxy:
  - Ansible Galaxy is a repository for Ansible Roles that are available to drop directly into your Playbooks to streamline your automation projects <https://www.redhat.com/sysadmin/ansible-galaxy-intro>
  - it is an online hub for finding and sharing ansible community content
  - `ansible-galaxy` is a command -line utility to install individual collections
    - `ansible-galaxy install <collection-name>`
- `command`: lets you execute commands on a server just like you would execite them manually
- `shell`: pretty much like command but shell executes command in the shell.
  - so the pipe operator `|`, redirect operators `>` or `<`, boolean operators `&&`, `||` and environment variables $HOME...etc that you have available in the shell, if you  need to use them, then you need to use the shell module.
  - `command` is more secure in terms of having these commands isolated and not running them directly through the shell, where as the shell module is more open to shell injection
- return values of modules:
  - ansible modules normally return data
  - this data can ne registered into a variable
  - `register`: the register attribute is available for any task/module.
    - it creates a variable and assigns that variable result of the module execution or task execution
  - `debug` module:
    - prints statements during execution
    - useful for debugging variables or expressions
- `command` and `shell` modules:
  - use only when no appropriate ansible module is available.
  - they are not idempotent because they do not have state management
- best practice: do not run the plays as a root user: create a new linux user and grant them the privileges to run the play:

  ```create linux user:
  - name: create linux user for nodeapp
  hosts: aws
  tasks:
    - name: create linux user
      user:
        name: phyllis
        comment: phyllis-admin
        group: admin
      register: user_creation_result
    - debug: msg={{user_creation_result}}
  ```

- privilege escalation: become
  - `become` allows you to become another user, different from the user that logged into the machine. default is *false*
  - `become_user`: set to user with desired privileges
    - Default is *root*

  ```become_user:
  - name: Deploy nodejs app
  hosts: aws
  become: True
  become_user: phyllis
  tasks:
    - name: unpack nodejs file
      unarchive:
        src: ../nodejs-app/package/nodejs-app-1.0.0.tgz
        dest: /home/phyllis
  ```

- registering variables:
  - create variables from the output of an Ansible task
  - this variable can be used in any later tasks in your play

- referencing variables
  - using double curly braces
  - if you start a value with {{ value }}, you must quote the whole expression to create a valid yaml syntax
  - this can be done several ways:
    - passing in variables using the - vars attribute: in the yaml file
    - on the comand line using `--extra-vars` flag or `-e` flag and passing the variables as key=value pairs
    - external variables file
      - the variables file uses yaml syntax, so you can use thte extension.yaml
  - naming of the variables:
    - not valid: python keywords like *async*, playbook keywords like *environment*, hyphens (linux-name), numbers only(12)
    - valid: letters, numbers, underscores
    - should always start with a letter
- `get_url` module:
  - Downloads files from HTTP, HTTPS or FTP to the remote server
  - separate module for windows targets: `win_get_url`
- `find` module
  - returns a list of files based on a specific criteria
  - for windows targets: `win_find` module
- conditionals:
  - exceute task depending on some condition
  - `stat` module:
    - retrieve file or file system status
  - `when` applied to a single task
    - no curly braces needed
    - the when statement applies the test
- `group` module;
  - manage presence of groups on a host
  - for windows: `win_group`
- `user` module
  - manage user accounts and user attributes
  - for windows: `win_user`
- `file` module
  - manages file and file properties
- `blockinfile` module:
  - insert/update/remove a multiline text surrounded by customizable marker lines
- `lineinfile` module:
  - ensures a particular line is in a file or replace an existing line using regex
  - useful when you want to change a single line in a file only
  - use "replace" module to change multiple lines
- `pause` module and `wait_for` module:
  - wait for specified time to pass before executing task

- `uname`: a command-line utility the prints basic information about the OS name and system hardware
- `lookup` plugins:
  - lookup plugins are an ansible specific extension to the jinja2 templating language
  - they allow ansible to access data from outside sources
  - `pipe` lookup plugin:
    - pipe is an ansible lookup plugin
    - it calculates the output of the shell command and pipes it to the left side of your lookup
- `systemd` Module
  - controls systemd services on remote hosts
- docker community collection
  - includes many modules and plugins to work with Docker
- Fully Qualified Collection Name(FQCN):
  - used to specify the exact source of a module/plugin/...
  - eg. community.docker.docker_image
  - ansible.builtin is the default namespace and collection name
  - recommended: used the FQCN so that you don't break code in case the backwards compatibility is removed at a future date/versions.
    - also because modules can have the same name and the FQCN ensures that Ansible uses the correct module/plugin/etc
- for verbosity: add -v(vv) flag to the command line when running the playbook.
  - the more v's the more the verbosity
- `docker-login` module
  - similar to "docker login" command
  - authenticates with a docker registry and adds teh credential to your local Docker config file
- interactive input: prompts
  - playbook prompts the user for a certain input
  - prompting the user for variables lets you avoid recording sensitive data like passwords. `vars_prompt`
  - you could also encrypt the entered values or put them in the `vars_files`

- __Working with Dynamic Inventory:__
  - inventory plugins(recommended over scripts for dynamic inventory)
    - they take advantage of the most recent updates to the ansible core code
    - the make use of ansible features including state management
    - written in yaml format
  - inventory scripts
    - written in python
  - plugins/scripts specific to infra provider
    - you can use `ansible-doc -t inventory -l` to see a list of available plugins
    - for AWS infra, you need a specific plugin/script for aws
    - pre-requisites:
      - boto3: aws SDK for python
        - needed to create, configure and manage aws services
      - botocore
  - ec2 inventory source
    config file must end with "aws_ec2.yaml"
  - ansible-inventory:
    - used to display or dump the configured inventory as Ansible sees it
    - `ansible-inventory -i inventory_aws_ec2.yaml --list`
      - to streamline the information we get from the command above, we can run this instead:
        - `ansible-inventory -i inventory_aws_ec2.yaml --graph`
    - assign public DNS to ec2 instances:
      - on the vpc: enable_dns_hostnames: true
  - configure Ansible to use dynamic inventory

- __Deploy to k8s__
  - Openshift python client is used to perform CRUD operations for k8s objects
    - openshift: python client for openshift platform
    - check if openshift module is present: `python3 -c openshift`
    - `pip3 install openshift --user`
  - PyYAML: Yaml parser and emitter for python
    - check if pyYaml is available: `python3 -c yaml`
    - `pip3 install PyYAML --user`
  - ** pip defaults to installing python packages to a system directory (such as /usr/local/libpython3.7). This requires root access
    - `--user` makes pip install packages in your home dir. this requires no special privileges
  - setting the kubeconfig env. variable:
    - `export K8S_AUTH_KUBECONFIG=~/.kube/config`

- __Ansible integration in Jenkins:__
  - install ansible on ubuntu server
  - install pip3, and then use pip3 to install boto3 and botocore
  - install awscli and configure credentials
  - __to convert an openssh key into an rsa format:__(acceptable format by jenkins)
    - `ssh-keygen -p -f.ssh/id_rsa -m pem -P "" -N ""`
  - on Jenkins UI: download ssh agent
  - add ansible key credentials: ssh username with private key
  - download plugin: ssh pipeline steps

- __Ansible Roles__
  - <https://spacelift.io/blog/ansible-roles>
  - Roles let you automatically load related vars, files, tasks, handlers, and other Ansible artifacts based on a known file structure. After you group your content into roles, you can easily reuse them and share them with other users.<https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html>
  - roles allow you to structure complax ansible project with lots of playbooks, tasks to be more manageable. you can group your content in roles so you breakup large palybooks into smaller manageable files.
  - they are like a package for your tasks in a play
  - variable precedence in ansible: <https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable>
