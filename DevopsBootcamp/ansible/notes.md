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
