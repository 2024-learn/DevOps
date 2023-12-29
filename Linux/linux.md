- Red Hat Package Manager:
    - `rpm`
    - `rpm -i` : install package
    - `rpm -e` : uninstall package
    - `rpm -q <package name>` : query package. eg. `rpm -q ansible python3 telnet`
    - `rpm -qa`: list all rpm packages. you can also grep for a specific package: `rpm -qa | grep ftp`
- Does not install dependencies

- `yum`: package manager that has rpm underneath. Will install package and its dependencies:
    - /etc/yum/repos.d directory

- View repositories available on the system:
    - `yum repolist`

- To see a list of installed or available packages:
    - `yum list`
    - `yum list <package name>` - specific package
    - `yum --showduplicates list <package name>` to show all available versions of a package
  
- Remove an installed package:
    - `yum remove <package name>`

### Services Basics

- `systemctl start <service name>` start service
- `systemctl enable <service name>` enable service to start automatically at bootup
- `systemctl stop <service name>` stop service
- `systemctl status <service name>` check the status of a service
- `systemctl disable <service name>` disable the service
- systemd files path: /etc/systemd/system
  
- To configure an app to runs as a new service. Create a file under /etc/systemd/system
  - name the file *.service e.g. my-app.service
  - In the file configure [Service]:
  - All other dependencies such as commands or scripts needed for the app to run, also go here:
  - `Restart=always` will help the app to restart whenever it crashes
    ```
    [Service]
    ExecStart=/usr/bin/python3 /opt/code/my-app.py
    ExecStartPre=/opt/code/configure_db.sh
    ExecStartPost=/opt/code/email_stat
    Restart=always

- Restart the daemon so that is knows that a new service has been configured: `sudo systemctl daemon-reload`
  - Then start the app: `systemctl start my-app`
  
- Configure the app to run at bootup under [Install].
    ```
    [Service]
    ExecStart=/usr/bin/python3 /opt/code/my-app.py
    ExecStartPre=/opt/code/configure_db.sh
    ExecStartPost=/opt/code/email_stat

    [Install]
    WantedBy=multi-user.target

- Then configure it to start at bootup: `systemctl enable my-app`. Remember to reload the daemon
  
- Add metadata to the config file under [Unit]:
    ```
    [unit]
    Description=My pythonweb app

    [Service]
    ExecStart=/usr/bin/python3 /opt/code/my-app.py
    ...

    [Install]
    WantedBy=multi-user.target

### Networking Basics

- `ip link`: list and modify the host's interfaces
- `ip addr` : list the ip addresses assigned to the interfaces
- `ip addr add` : used to set IP addresses on interfaces. e.g `ip addr add 192.168.1.10/24 dev eth0`. ps to persist these changes after a restart, you must set them in the /etc/network interfaces file
- A switch can only enable communication within a network
- A router helps connect two networks
- `route` shows the existing routing configuration on a system. It displays the kernel's routing table
- `ip route add` will configure systems on different networks to reach each other/ add entries to the routing table
  - `ip route add 192.168.2.0/24 via 192.168.1.1`
  - `ip route add default via 192.168.1.1` or `ip route add 0.0.0.0 via 192.168.1.1`

- The setting for whether a host can forward packets between interfaces is governed by a setting in : /proc/sys/net/ipv4/ip_forward.
  - Default is 0 (no forward, meaning no pings can go through). you can change it to 1
  - This does not persist through reboots so to do that change the setting in 
  ```
  /etc/sysctl.conf 
  ... 
  net.ipv4.ip_forward = 1
  ...

### DNS

- Change a hostname by making an entry in /etc/hosts file:
    ```
    cat /etc/hosts
    192.168.1.11    db

- Name resolution: translating host name to IP address.
- This gets cumbersome as the network grows. Therefore this was moved to a centrally managed single server - the DNS server
- We then point all hosts to look uo that server if they need to resolve a hostname to an ip address. Add an entry to the /etc/resolv.conf     file specifying the address of the DNS server
- `nameserver    192.168.1.100`
- the system looks at the /etc/hosts file before checking the /etc/resolv.conf file. That order can be changed by an entry in 
  /etc/nsswitch.conf
  ```
  cat /etc/nsswitch.conf
  ...
  hosts:    files dns
  ...
- The order here is first files (/etc/hosts) then dns (dns server)
- To ping an address that is not in either files, you can add the address to /etc/resolv.conf e.g. `nameserver   8.8.8.8`


- Domain Names
- .com .net. .edu .org .gov ==> top level domain names and represent the intent of the website
- `.`: root
- `.com`:  Top level domain
- `google`:
- `mail` `apps` `drive` : subdomain
- When you try to reach any of these domain names, eg. maps.google.com from within your org, the request first hits your org's internal
  dns server. Since it does not know who that hostname belongs to, it forwards your request to the internet. On the internet the IP address of the server serving apps.google.com may be resolved with the help of muliple DNS servers
- A root DNS server looks at your request and points you to a DNS server serving .coms.
- A .com DNS server looks at your request and forwards you to Google.
- Google DNS server provides you the IP of the server serving the maps application
- Record types:
- A        ipv4
- AAAA     ipv6
- CNAME    aliases (maps one name to another name/ name to name mapping)
- MX       mail records
- `nslookup` used to query a hostname from a DNS server. It however does not consider the entries in the local /etc/hosts file. it only queries the DNS server
- `dig` used to test the DNS name resolution
- Locally resolve news.yahoo.com to news in /etc/resolv.conf
  - `news news.yahoo.com`

### Application Basics

#### Java
- Java Development Kit: It is a set of tools that will help you develop, build and run Java applications on a system.
- `jdb` java debugger tool
- `javadoc` javadoc tool to document your application source code. eg.
  - `javadoc -d doc MyClass.java` => HTML version of the domumentation of the code
- `javac` used to build and compile the application
- `jar` helps archive the code in related libraries
  - It helps compress and combine multiple java.class files and dependent libraries and assets into a single distributable package.
  - when you have other files such as static files and images that are part of the java app, 
    the files are packaged into a `war` (Web Archive)file
  - To create an archive, use the jar command and specify the name of the output file,in this case `MyApp.jar`
   then pass in the list of files that need to be part of the archive.
    - `jar cf MyApp.jar MyClass.lass Service.class Service2.class ...`
  - When MyApp.jar file is created, it automatically generates a manifeset file within the package at path: /META-INF/MANIFEST.MF
  - It contains information about the files packaged in the jar file and any other metadata regarding the application.
    - Entrypoint: Main-Class
- when running a jar file: `java -jar MyApp.jar`
- Once built, you need `jre`- java runtime environment, to run a java app on any given system
- You aslo need the java command line utility or loader that is used to run in the application
- After version 9, JDK and JRE are packaged together

Build Tools
- Popular build tools for Java are: Maven, ANT, Gradle
- Build Steps: Compile, Package, Document
- ANT- build.xml.
- `ant` will carry out all the steps specified in the build configuration file (build.xml)
- if you want to specify on which steps to skip, e.g. only compile and jar:
  - `ant compile jar`
- Maven- pom.xml has the build instructions configured. e.g. maven instructions
  - `mvn clean install`
- Gradle: build app: `./gradlew build` Run App: `./gradlew run`

#### node.js
- `curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -`(deprecated)
- `yum install nodejs`
- `node -v` lists node version
- `node *.js` run the application. e.g `node checkout.js`
