# Linux Notes

OS acts as the intermediary and translator between applications and the hardware.

__OS Tasks:__

- Resource allocation and management
  - Process management
    - process: a small unit that executes on a computer
    - each process has its own isolated space
    - isolates content of applications so applications are not interfering with each other's resources
    - When a computer only has 1 CPU, it can only process one task at a time.
    - It's just that that CPU switches fast enough for us not to notice
    - the more the CPU's the faster the applications work
  - Memory management
    - allocating work memory
    - memory swapping: OS unloads memory or basically clears that memory storage for an app
     and then saves it into a secondary memory,the storage, and loads the new processes/data in that cleared memory
      - the OS swaps memory between applications.
      - When the memory is full, it decides which app becomes inactive and a new process/app gets the resources
        - this slows down the computer because swapping takes time
  - Storage management
    - Also called "secondary memory".
    - a computer mainly has two storages:
      - the Rapid Access Memory(RAM) and a hard drive storage that is responsible for persisting data long-term
- Manage file system
  - store in a structured way with files and folders
  - in Unix systems: tree file system
    - in Windows OS: multiple root folders
- Management of I/O Devices
  - OS knows how to handle and translate interactions between apps and devices
- Security and Networking
  - Managing users and permissions
    - each user has its own space and its permissions
  - networking: assigning ports and IP addresses

- __Operating System Components__
- Kernel
  - kernel is a program written in code which consists of device drivers
     and some other logic like dispatcher scheduler, file system, etc.
  - the part of the OS that loads first when you turn on a computer
  - responsible for managing the hardware components
  - handles I/O devices using various device drivers
  - the kernel is the layer interacting between the applications and the hardware.
  - so when you start an application, it is the kernel that starts the process for the app, allocates resources to the app
    - it also cleans up the resources when the app shuts down.
- Application layer
  - a layer on top of the kernel.
    - e.g. different Linux distributions. These are different application layers but based on the same Linux kernel
    - Android is based on a Linux distribution
    - MacOs and iOS use Darwin which is the same kernel but a different application layer
    - operating systems for servers. mostly based on Linux, more lightweight and performant
      - no GUI or other user applications
  - How to interact with the kernel:
    - GUI or CLI.
    - kernel cannot be used without the OS user layer

- __Linux File System__
- /bin
  - binaries executables for most essential user commands
  - contains the most basic commands
  - binary: computer readable format
- /sbin
  - system binaries
  - these binary commands are system relevant
  - they need super user permission to execute them
  - used by the system and system admins to administer the system
- /lib
  - essential shared libraries that executables from /bin and /sbin use
- /usr
  - this was formerly the user folder for home directories before home directory was added
  - historically, because of storage limitations it was split into root binary folders and user binary folders
  - most of the commands are still executed from this folder.
  - some systems have less commands in the /bin and /sbin folders and more commands in the /usr/bin
     and /usr/sbin folders
    - /usr/local
      - location where the applications that the user installs on the computer go
      - third-party applications like docker, minikube, java ...
  - programs installed on /usr are available to all users on the computer
- /opt
  - optional folder
  - for third party programs
  - difference between /usr/local and /opt is that there are some applications that do not split their code or their
     files in different directories.
    - /usr/local is for programs that split its components
    - /opt os for programs that do not split their components
  - also available to all users on the computer
- boot
  - contains files required for booting the system. Should not be modified
- /etc (et cetera)
  - location where configuration for system-wide applications is stored. it is the main configuration location
  - you can modify the configuration here as needed
- /dev
  - location of device files that are connected to your computer; like webcam, keyboard, hard drive, etc.
  - Apps and drivers will access this, not the user
  - This is for files that the system needs to interact with the device
- /var
  - when the system starts, it logs some data and these logs are stored in /var
  - it contains files to which the system writes data during the course of its operation
    - /var/log
      - contains log files
    - /var/cache
      - contains cached data from application programs
    - generally, the /var folder is for storing logs from different processes that are running on your computer
- /tmp
  - temp directory
  - temporary resources required for some process/application are kept here temporarily, then eventually deleted
- /media
  - removable media
  - contains subdirectories, where removable media devices inserted into the computer are mounted
  - e.g when you insert a CD, a directory will automatically be created
     and you can access the contents of the CD inside the directory
- /mnt
  - temporary mount point
  - historically, sys amins mounted temporary file systems here
- hidden files:
  - start with a .dot
  - in Unix also called "dotfiles"
  - primarily used to help prevent important data and configuration from being accidentally deleted
  - usually automatically generated by programs or operating systems eg. .zshrc .bash .mozilla ...
  - can also be user generated eg. .ssh .git ...

- __Basic Commands__
- `rm -r <dirname>`: delete a non empty directory and all the files within it
- `rm -d <dirname>` or `rmdir <dirname>`: delete an empty directory
- `ls -r <dirname>` : list files and folders recursively
- `CTRL + r` : back search/ reverse search the history. It will grep for any commands with the letters you just typed
- `history 2`: will show last 2 or `n` commands you specify
- `uname -a`: show system and kernel
- `cat /etc/os-release`: will show you the distribution and version
- `lscpu`: list info about CPU
- `lsmem`: list info about memory

- __Installing Software on Linux__
- software package:
  - this a compressed archive, containing all the required files
  - apps usually have dependencies which are sometimes not packaged in the software package, so they have to be installed in order for it to run.
- package manager:
  - downloads, installs or updates the existing software from a repository
  - ensures the integrity and authenticity of the package
  - manages and resolves all required dependencies
  - knows where to put all the files in the Linux file system. eg. binaries, shared folders, libraries, etc.
  - easy upgrading/ installing/ uninstalling of the software
  - Ubuntu: `apt` (Advanced Package Tool)
    - `sudo apt search <package name>`: search for a package
    - `sudo apt install <package name>`: install one package
    - or  `sudo apt install <package name> <package name>` install multiple packages
    - `sudo apt remove <package name>`: remove package
    - Alternative package manager: `snap`
      - also referred to as "snappy"
      - `snap` is a bundle of an app and its dependencies. it is self contained
      - snap store provides a place to upload snaps, and for users to browse and install the software
      - snapcraft: the command and framework used to build and publish snaps
      - the format of the file is also called snap
    - difference between `snap` and `apt`:
      - `snap`:
        - self-contained- the dependencies are contained in the package. Therefore, different applications cannot share the dependencies which exist in another already downloaded package. Its storage usage is not efficient.
        - supports universal Linux packages (package type `.snap`)
        - automatic updates
        - larger installation size
      - `apt`:
        - dependencies are shared, so multiple applications can use the same dependencies
        - only for specific linux distributions. (package type `.deb`)
        - manual updates
        - smaller installation size
    - Another alternative: Add repository to official list of repos (`add-apt-repository`)
      - add repository to `apt` sources (/etc/apt/sources.list)
      - use case: when installing relatively new applications that are not in the official repository yet
      - repository will be added to /etc/apt/sources.list file. After it is added, you can use the apt package manager to install the package
      - the next `apt install <package name>` will also look into this newly added repository
      - PPA = personal package Archive
        - PPAs are provided by the community
        - Anybody can create this PPA- private repository to distribute the software
        - usually used by developers to provide updates more quickly than in the official ubuntu repos
        - Beware the possible risks before adding a PPA
          - no guarantee of quality or security
          - like any other unofficial software package, it can cause difficulties e.g. when upgrading to a new Ubuntu release
    - Linux distros are grouped, based on same source code
    - distros in the same category, use the same package manager
      - debian based: eg. Ubuntu, Debian, Mint all use `apt` or `apt-get`
      - Red Hat based: eg. RHEL, CentOs, Fedora, use `yum`

- __vi/vim in command mode:__
- `shift + a`: jump to the end of the line and get into insert mode
- `u`: undo the last command
- `d<number>d`: deletes the number of lines specified in the command. eg. d10d will delete 10 lines
- `dd`: deletes the entire line
- `0` or `$` = jump to the start of the line
- `12G` = go to line 12 ...
- `x`: deletes a character
- `/pattern`: will search for all instances where that pattern is / globally on that file.
- `n`: jump to the next match
- `N`: search in the opposite direction
- `%s/old/new` replace old string with new string throughout the file
- `i` switch to insert mode

- __Users and Permissions__
- user categories:
  - superuser account
  - user account
  - service account. each service gets its own user
    - best practice: Do not run services with root user!
- Multiple users on linux: User accounts are managed on that specific hardware
- How to manage permissions
  - user level: give permissions to user directly
  - group level: group users into linux groups and giving the group the permission
    - this is the recommended way, if you manage multiple users

- Access control files
  - /etc/passwd:
    - store user information
    - everyone can read it, but only root user can change the file
      - username:password:uid:gid:gecos:homedir:shell
      - username: used when a user logs in
      - password: x means that encrypted password is stored in /etc/shadow file
      - userID(UID): each user has a unique ID. UID 0 is reserved for root
      - groupID(GID): the primary group ID for the user(stored in /etc/group file)
      - userID Info: comment field for extra information about users. (user description, full name, etc.)
      - home directory: absolute path of user's home directory
      - Default shell: absolute path of a user's default shell
    - /etc/shadow
    - /etc/group
    - Do not edit the access control files with a text editor, instead use the CLI
  - `sudo adduser <username>`: create new user
  - e.g `sudo adduser phyllis`
    - `cat /etc/passwd`
    - automatically chooses policy-conformant UID and GID values
    - automatically creates a home directory with skeletal configuration
- `sudo passwd <username>`: change user's password
  - `cat /etc/shadow`
- `su - <username>`: switch user
  - `sudo -i` or `su -` : login as root
- `sudo groupadd <group name>`: create a new group
  - By default, system assigns the next available GID from the range of group IDs specified in the login.defs file
  - e.g. `sudo groupadd sre`
  - `cat /etc/group`
- `usermod [options] <username>`: modify a user account
  - e.g. `sudo usermod -g sre phyllis`
  - A user can be part of multiple secondary groups and therefore gains the permissions of each group that they are part of.
    - `sudo usermod -G group1,group2 <username>`
    - e.g. `sudo usermod -G devops,admin phyllis`
  - **Please note that capital `-G` will overwrite the whole of the secondary groups list**
    - to avoid that use `-aG` to append to the list
    - e.g. `sudo usermod -aG admin,devops,it phyllis`
    - `sudo usermod -aG sudo phyllis`: adds phyllis to the sudoers group
- `sudo deluser <username>` or `sudo deluser <username>`: delete user
- `sudo groupdel <groupname>` or `sudo delgroup <groupname>`: delete group
- `groups`: displays the groups that the currently logged in user belongs to
- `groups <username`:  display the specified user's groups
- ** `useradd [options] <username>` Will also create a new user
  - it is a low-level command compared to `adduser`
  - `-G`: create user with multiple secondary groups
  - `-d`: custom home directory
  - and other options for shell, etc.
  - e.g. `sudo useradd -G devops tom`
    - ps. this will still create the primary group
- `sudo gpasswd -d tom devops`: remove a user from a group

- __File Ownership and Permissions__
- There are two concepts in managing files: Ownership and Permissions
- ownership: who owns the files/folders
  - ownership levels:
    - user: the owner is usually the user who created the file
    - group: the owning group is the primary group of that user
  - `sudo chown <username>:<groupname> <filename>`: change user and group ownership of a file
  - `sudo chown <username> <filename>`: changes the user ownership
  - `sudo chgrp <groupname> <filename>`: change the group ownership of a file
- permissions: who can do what with the file
  - file types:
  - `-`: regular file
  - `d`: directory
  - `c`: character device file
  - `l`: symbolic link
  - etc.
  - permission types:
    - `rwx-`: read write execute no permission
    - drwxrwxr-x
      - d: directory
      - rwx: owner  (u)
      - rwx: group  (g)
      - r-x: others- (o) all other users who are not the file owner or don't belong to the group owner
  - change file permissions
    - `sudo chmod -x <filename>`; remove executable permissions from file, for all users
    - `sudo chmod ug+x <filename>`: add executable permissions to file, for user and group
    - `sudo chmod o-x <filename>`: remove executable permissions for others
    - `sudo chmod a+w <filename>`: add write permissions for all
  - change multiple permissions:
    - `sudo chmod g=rwx <filename>`: add rwx permissions for group
    - `sudo chmod o=r-x <filename>`: add read, execute perms for others
    - `sudo chmod g=r-- <filename>`: add read only perms for group
  - permissions with numeric values:
    - `sudo chmod 777 <filename>`: rwx permissions for all
    - `sudo chmod 740 <filename>`:rwx for user, r for group, no permissions for others

- __Pipes and Redirects__
- Pipe `|`: allows the output of one command to be the input of another command
  - e.g. `cat /var/log/syslog | less`
    - `history | less`
  - pipe and grep
    - `history | grep <pattern>`
    - e.g. `history | grep apt`
    - grep (Globally search for Regular Expression and Print out)
    - searches for a particular pattern of characters and displays all lines that contain that pattern
    - search multiple words. put in quotes:
      - `history | grep "sudo chmod"`
- Redirect `>` or `>>`: redirect the output of a command to save to a file, for example.
  - takes the output from the previous command and sends it to a file that you give
  - e.g. `history | grep sudo > history.txt`
  - `>` will overwrite
  - `>>` will append
- Standard Input and Standard Output
  - every program has 3 built-in streams:
    - STDIN (0): standard input
    - STDOUT (1): standard output
    - STDERR (2): standard error
    - command -> stdout -> stdin -> command -> stdout
- combining commands that don't share inputs or outputs:
  - clear; ls; history
  - clear && ls && history

- __Shell Scripting__
- shell: the program that interprets and executes the various commands that we type in the terminal and translates the command so that the OS kernel can understand it
- basically, it is a command interpreter and interface between the user and the kernel
- There are different shell interpretations
  - sh (bourne shell) - /bin/sh
    - used to be the default shell
  - bash (bourne again shell) - /bin/bash
    - improved version of sh
    - default shell program for most UNIX like systems
  - zsh, csh, ksh ...etc
- Shell and bash terms are often used interchangeably
- bash is a shell program and a programming language
- Shebang: tells the OS which shell to use
  - `#!/bin/bash` `#!/bin/sh` `#!/bin/zsh`
  - it points to the absolute path of the interpreter of your shell
  - to execute `./<filename>`. this however will not work unless the file has executable permissions
    - `sudo chmod +x <filename>`: will add executable permissions for everyone

- Basic concepts and syntax
- variables:
  - used to store data and can be referenced later
  - note: There must be no spaces around the "=" sign
- conditionals:
  - allow you to alter the control flow of a program
  - [...] built-in command: square brackets enclose expressions
  - test if it is a directory `-d`. it is the shorthand notation for the test command: if test -d "config" is the same.
- __File Test Operators__: test various properties associated with a file (ref: <https://tldp.org/LDP/abs/html/fto.html>)

| Operator  |  Description                                                              |
|-----------| --------------------------------------------------------------------------|
| -b        | checks if file is a block special file                                    |
| -c        | checks if file is a character special file/ character device              |
| -d        | checks if the file is a directory                                         |
| -e        | check if file exists                                                      |
| -f        | checks if it's an ordinary file                                           |
| -g        | checks if file has set group GID (SGID) bit set                           |
| -h        | checks if file is a symbolic link                                         |
| -k        | checks if file has its sticky bit set                                     |
| -p        | checks if the file is a pipe                                              |
| -t        | checks if file descriptor is open and associated with a terminal device   |
| -u        | checks if file has a set user ID (SUID) bit set                           |
| -r        | checks if file is readable                                                |
| -w        | checks if the file is writable                                            |
| -x        | checks if the file is executable                                          |
| -s        | checks if file has a size greater than 0                                  |
| -S        | checks if the file is a socket                                            |

- __Relational Operators__
- works only for numeric values
- will work to check relation between 10 and 20 as well as "10" and "20"

| Operator  | Description                                                   |
| --------- |---------------------------------------------------------------|
| -eq       | checks if the value of 2 operands are equal or not            |
| -ne       | checks if 2 operands are not equal, then condition is true    |
| -gt       | checks if left operand is greater than the right              |
| -lt       | checks if left operand is less than the right                 |
| -ge       | checks if left operand is greater or equal to the right       |
| -le       | checks if left operand is less or equal to the right          |

- __string operators__
  
| Operator  | Description                                                                       |
| --------- |-----------------------------------------------------------------------------------|
| ==        | checks if the value of 2 operands are equal or not. if yes; true                  |
| !=        | checks if 2 operands are not equal, if not equal; true                            |
| -z        | checks if the given string operand size is zero, if zero length; true             |
| -n        | checks if the given string operand size is non-zero; if non-zero length; true     |
| __str__   | checks if __str__ is not empty string; if it's empty, the condition returns false |

- Positional parameters
  - Arguments passed to the script are processed in the same order in which they are sent
  - the indexing of arguments starts at $1 to $9

- `echo` lets you use the new line character `\n` to print a new line within the same output line if you use the `-e` option
  - e.g. echo -e "Name\nAddress\nPhone Number"
    - ref:
    - <https://linuxhandbook.com/echo-newline-bash/>
    - <https://linuxhandbook.com/bash/>

- read all the parameters that the user passes in
  - `$*`: represents all the arguments as a single string
  - `$#`: represents the total number of parameters passed in
  - `$?`: captures value returned by the last command
- __loops in linux__
  - Enable you to execute a set of commands repeatedly
  - there are different types of loops:
  - __while__ loop:
    - execute a set of commands repeatedly until some condition is matched
    - `break` command: exits from a __for__, __while__, __select__, or __until__ loop

     ```while loop
     while condition
     do
       statement(s) to be executes if command is true
     done
     ```

  - __for__ loop:
    - ref: <https://www.cyberciti.biz/faq/bash-for-loop/>
    - operates on a list of items
    - repeats a set of commands for every item in the list

     ```for loop
     for var in word1 word2
       do
           statement(s) to be executed for every word
       done
     ```

    - __until__ loop:
      - refs:
      - <https://phoenixnap.com/kb/bash-loop-until>
      - <https://www.geeksforgeeks.org/bash-scripting-until-loop/>
      - <https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_09_03.html>
    - __select__ loop
      - refs:
      - <https://www.oreilly.com/library/view/shell-scripting-expert/9781118166321/c06-anchor-7.xhtml>
      - <https://bash.cyberciti.biz/guide/Select_loop>
- use double parentheses for arithmetic operations or bash reads it as a string concatenation
  - $(( 2+4 ))
  - $(( $num1 + $num2 ))
- bash has an alternative for the square brackets that we use for conditionals and __if__ expressions. [[ ... ]]
  - one of the advantages of using the double brackets is that you do not have to enclose the variable names in quotes
  - e.g `if [ "$score" == "q"]` is the same as `if [[ $score == q ]]`

- __Functions__
- Enable you to break down the overall functionality of a script into smaller, logical code blocks

```function
function func_name () {
   list of commands
}
func_name
```

- this code block can then be referenced anywhere in the script multiple times
- you have to call/invoke the function for it to work

- __pass parameters to a function:__
  - the parameters are passed in represented by $1, $2, etc.
  - best practices:
    - do not use too many parameters
    - apply the single responsibility principle: a function should only do one thing
    - declare variables with a meaningful name for positional parameters within a function
- __Returning values from functions:__
  - A return is a value that a function returns to the calling script or function when it completes its task. A return value can be any one of the four variable types: handle, integer, object, or string. The type of value your function returns depends largely on the task it performs.
  - <https://ioflood.com/blog/bash-function-return-value/>

   ```sum-function
   function sum(){
       total=$(($1+$2))
       return $total
   }
   sum 2 10
   result=$?
   echo "the sum of 2 and 10 is: $result"
   ```

- __Environment Variables__
- key=value pairs
- env. vars are available for the whole environment.
- by convention, names are defined in uppercase
- List all env vars: `printenv`
  - print specific env vars: `printenv <variable name>`
    - e.g. `printenv USER`
    - `printenv | grep USER`
    - `echo $USER`
- Use cases:
  - storing sensitive data for an application
  - make application more flexible, making it easier not to have to change application code in different envs.
- Setting env. vars.
  - `export DB_USERNAME=dbuser`
  - `export DB_PASSWORD=secretpwdvalue`
  - `export DB_NAME-mydb`
- deleting env. vars:
  - `unset <env. var name>`
  - `unset DB_NAME`
- Persisting env. vars
- __Shell specific configuration file__
  - per-user shell configuration files
    - e.g. if you are using Bash, you can declare the variables in the ~/.bashrc file
  - variables set in this file are loaded whenever a bash login shell is entered
    - in zsh it is ~/.zshrc
  - after adding the variables, source the file to reload the system to load and recognize environment variables you just entered,.
    - `source ~/.zshrc` or `source ~/.bashrc` ...
- __System wide for all users:__
  - in /etc/environment
  - PATH environment variable:
    - list of directories to executable files, separated by `;`
    - Tells the shell which directories to search in for the executable in response to our executed command
    - ref:
      - <https://www.tecmint.com/set-unset-environment-variables-in-linux/>
      - <https://www.freecodecamp.org/news/how-to-set-an-environment-variable-in-linux/>
      - <https://www.cyberciti.biz/faq/set-environment-variable-linux/>

- __Networking__
- __LAN, Switch Router, WAN, Gateway__
- __LAN:__ Local Area Network
  - Collection of devices connected together in one physical location. eg. a home network, office building or a campus
  - each device has a unique IP address
  - Devices can communicate to each other on these IP addresses
  - 32 bit value: 00000000 => 0
  - 1 bit = 1 or 0: 11111111 => 255
  - IP addresses can range from 0.0.0.0 to 255.255.255.255
- __switch:__
  - sits within the LAN
  - facilitates the connection between all the devices within the LAN
- __router:__
  - sits between LAN and outside networks (WAN)- __Wide Area Network__
  - it connects devices on the LAN and WAN
  - Allows networked devices to access the internet
- __gateway:__
  - This is the IP address of the router
- __subnet:__
  - When a device sends communication to another device on the LAN, how does it know whether the device is within or outside the LAN?
    - it knows because of the IP address of the target device
  - Devices in the LAN belong to the same IP address range
  - __subnet__ is a logical subdivision of an IP network
  - __subnetting__ is the process of dividing a network into two or more networks
  - __subnet mask__ dictates how many bits are fixed
  - 1 octet/IP block = 8 bits
  - Subnet sets the IP range
    - Example of IP address range:
    - 192.168.0.x: IP address (starting point)
    - 255.255.255.0: subnet mask
    - All IP addresses starting with 192.168.0.x belong to the same LAN

    - 192.168.x.x: IP address
    - 255.255.0.0: subnet mask
    - All IP addresses starting with 192.168.x.x belong to the same LAN
  - 255.255.0.0 - means that 16 bits are fixed
  - 255.255.255.0 - means 24 bits are fixed
  - value 255 fixates the Octet
  - value 0 means free range
  - subnet defines how many bits in the IP address are fixed making the rest of them flexible.
- __address ranges:__
  - | starting IP   | subnet mask       | last IP address   |
    |---------------|-------------------|-------------------|
    | 192.168.0.0   | 255.255.255.0     | 196.168.0.255     |
    | 192.168.0.0   | 255.255.0.0       | 192.168.255.255   |
- __CIDR block:__
  - CIDR = Classless Inter-Domain Routing
  - 255.255.0.0   - means that 16 bits are fixed
  - 255.255.255.0 - means 24 bits are fixed
  - CIDR block would be written as:
    - 192.168.0.0/16 or 192.168.0.0/24
      - where the numbers after the dash represent the number of bits that are fixed
        - /16 bits are fixed
        - /24 bits are fixed
- __Recap__
  - We have a range of IP addresses that are available on the LAN
  - All devices in the LAN get a unique IP address from that range
  - When we send a request to an address within the LAN, the request will go to the switch and forward it to the device within the LAN.
  - when we send a request to an address outside of the LAN, it will go to the internet through the router
  - Any device needs three pieces of data for communication: IP address, subnet, gateway.
- __Network Address Translation:__
  - How to make sure IP addresses do not overlap from one LAN to another?
  - IP addresses within LAN are not visible to the outside network or internet
  - e.g. when interacting with social media, your device's private IP address does not reach the router. it is replaced by the router's IP address
  - __NAT:__ This is the key functionality of a router
  - __Benefits of NAT:__
    - Security and protection of devices within the LAN
    - Reuse IP addresses without conflicting with each other. So, 2 LANS can have the same IP address range within their LAN because they basically will not know about each other, hence no conflict.
- There are a limited number of IPv4 addresses:
  - 4,294,967,296 : 256*256*256*256
- __Firewall:__
  - By default, a server is not accessible from outside the LAN
  - __firewall__ is a set of rules that protect a network from unauthorized access
  - Using firewall rules, we can define which requests are allowed
  - __port:__
    - every device has a set of ports. You can allow specific ports and IP addresses.
    - different applications listen on specific ports
    - there are default or standard ports on many applications
    - e.g web apps on port 80, mongodb on 27017, mysql 0n 3306, postgresQL on 5432...etc.
    - You need a port for every application. and each port is unique in a device, so you cannot have two applications listening on the same port
  - So, firewall allows device IP address at port to be accessed. This is also known as __port forwarding configuration__
  
- __Domain Name Service (DNS):__
  - ref: <https://www.cloudflare.com/learning/dns/glossary/dns-root-server/>
  - Humans are better at remembering words and names instead of numbers.
  - However, the computer does not understand names, it understands numbers and IP addresses.
  - Hence, the concept of mapping IP address to names was introduced
  - Under the hood, that name is translated into an IP address that the application is running on which your computer can send the request to. The service that does this translation of domain names into IP addresses is __DNS__.
- __How does DNS manage all these IP addresses?__
  - ![DNS](https://mykbhome.files.wordpress.com/2019/07/image-2.png)
  - DNS uses a simple policy of dividing all these names into different domains or groups
  - Domain names follow a hierarchical structure.
  - __Root Domains `.`:__ ref: <https://www.iana.org/domains/root/servers>
  - Root servers are DNS nameservers that operate in the root zone. These servers can directly answer queries for records stored or cached within the root zone.
  - ![list of root servers](https://mykbhome.files.wordpress.com/2019/07/image-4.png)
  - __Top Level Domains:__
    - there are 6 original TLDs: .mil, .edu, .com, .org, .net, .gov
    - there are also geographical domains that were added later. eg. .at, .fr, .uk, .us, .ke, .za,
    - These are used to also regulate domains for companies that are registered in that country.
      - eg.<www.bmw.de>, <www.safaricom.co.ke>
    - then other top-level domain names were added: e.g. .biz, ,init, .dev, etc.
    - __who can manages these names?__
      - This is all done by ICANN(Internet Corporation for Assigned Names and Numbers)
      - manages the TLD development and architecture of the internet domain space
      - Authorizes __Domain Name Registrars__, which register and assign domain names
    - __subdomains:__
      - Many companies use subdomains for different applications that belong to the same organization.
      - Each application may run on a different server with its own unique IP address and now will have a full domain name, with which it can be accessed
  - __Fully Qualified Domain Name (FQDN)__
    - refs:
      - <https://www.techtarget.com/whatis/definition/fully-qualified-domain-name-FQDN>
      - <https://www.hostinger.com/tutorials/fqdn>
    - A fully qualified domain name (FQDN) is the complete address of an internet host or computer. It provides its exact location within the domain name system (DNS) by specifying the hostname, domain name and top-level domain (TLD). For example, for the domain name <www.whatis.com>, "www" is the hostname, "whatis" is the domain name and ".com" is the top-level domain.
  - __How does DNS resolution work?__
    - Every computer has a DNS client preinstalled. when you type in <www.thatwebsite.com>, your OS makes a DNS query asking DNS to resolve that address to an IP address or find the IP address that maps to thatwebsite.com.
    - the DNS request first goes to the recursive name server which is typically operated by your Internet Service provider.
    - the cursive name server might have the IP address already stored. if it doesn't, then it will go to one of the 13 root servers which manage requests for top level domains.
      - these root servers are redundantly available all over the world to make getting responses quicker.
      - the root server will then look at the address and see .com; it sends a response back to the resolver with the address of the top-level domain server.
      - the resolver then asks the .com __top-level domain server__
        - top-level domain server stores the address information of top-level domains.
      - The .com server sends a response to the resolver with a list of the IP addresses of the __authoritative name servers__ for .com domain
        - the __authoritative name server__ is responsible for knowing everything about the domain, including the IP address.
      - so, finally, resolver chooses the IP address of the authoritative name servers from the list, asking for thatwebsite.com's IP address and this time, the name server responds with the actual IP address of thatwebsite.com
      - now your computer can send the request to thatwebsite's IP address.
      - This happens the first time you visit a website. To save time in the future and make the process more efficient, DNS entries are cached for efficiency. both the recursive name server/ISP and computer cache the DNS entries for a while so that the next time you request for that address, it will not have repeat the whole process.
- __networking commands:__
  - `ifconfig`: lists the computer's IP address, subnet mask, gateway address(router IP address) and other info about your network
  - `netstat`: Shows what active connections you have on your machine
    - active connections: which applications are actively listening on their specific ports
  - `ps aux`: checks for current running processes and programs, and their information including on which ports they are running, as well as how much computer resources they are consuming
  - `nslookup`: shows the IP address of any domain name
    - `nslookup google.com`
    - It also shows the IP address of the DNS server your computer uses
    - or you can also do a reverse check with `nslookup` command to show what domain name is attached to a specific IP address.
  - `ping`: basically checks whether a service or application is accessible
    - uses the ICMP protocol. Note: if the application is not pingable, it is not necessarily that the app is down/unavailable but that ICMP has been blocked by the firewall, likely for security reasons
 __SSH (Secure Shell)__ ref: <https://www.atlassian.com/git/tutorials/git-ssh>
-
- SSH is a network protocol that gives users a secure way to access a computer over the internet
- SSH refers also to the suite of utilities that implement that protocol
- SSH authentication comes after the connection
  - firewall and port: 22
    - source: who can access the port?
    - SSH is powerful and needs to be restricted to specific IP addresses
  - generate ssh key pair:
    - Before adding the new SSH key to the ssh-agent first ensure the ssh-agent is running by executing:
      - `eval "$(ssh-agent -s)"`
    - by default stored under `~/.ssh` folder
    - `ssh-keygen -t rsa -b 4096 -C "youremail.example.com`
      - `t`: type (of encryption) flag
      - `rsa`: the cryptographic algorithm that is going to be used to encrypt the keys
      - the command will create a new SSH key using the email as a label
    - you can now view the key: `cat ~/.ssh/id_rsa` for private key and `cat ~/.ssh/id_rsa.pub` for public key
    - You can now add the public key you generated on your machine in the remote server in ~/.ssh/authorized_keys
    - __known_hosts__: lets the client authenticate the server to check that it isn't connecting to an impersonator
    - __authorized_keys__: lets the server authenticate the user
      - careate a new user:
        - `sudo adduser phyllis`: creates new user phyllis
        - `sudo usermod -aG sudo phyllis`: adds user phyllis to sudoers group
      - on the local machine generate keys with `ssh-keygen`
        - copy the pub key: `cat ~/.ssh/id_rsa.pub`
      - on the server in the home of the user:
        - `mkdir ~/.ssh`
        - `touch authorized_keys`
        - vim ~/.ssh/authorized_keys and paste the public key
      - now on the host machine you can ssh into the machine as `ssh phyllis@<public ip of the remote server>`
    - `scp`__secure copy__: Allows you to securely copy files and directories
      - secure, meaning files and password are encrypted
      - `scp test.sh root@IP address:/destination`
      - if the key is not in the default location or differently named:
        - `scp -i ssh/id_rsa test.sh root@IPaddress:/destination folder`
