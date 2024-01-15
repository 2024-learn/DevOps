# Jenkins
- __Install Jenkins:__
  - 
  - Install Jenkins as a Docker container:
    - Create jenkins container with mounted docker
      - `docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts`
      - port 8080 is the default port for Jenkins
      - port 50000 is where Kenkins and worker nodes communicate
      - `-v` mounts the volume to `jenkins_home` 
        - When we configure Jenkins, create users in Jenkins, create jobs to run different workloads, install plugins, etc. Jenkins will store these as data, which needs to be persisted.
        - jenkins_home-- not yet created but docker will create a physical path on the server (host) to store the data and we can reference it.
        - we are going to attach that volume on the server to the container (/var/jenkins_home). 
          - So the data is initially written on the container path then replicated on the host.
      - jenkins/jenkins:lts it the official docker image
  - Now you can access Jenkins from the browser: <IP>:8080
  - access Jenkins. the initial password is located at: `/var/jenkins_home/secrets/initialAdminPassword`inside the container.
    - `cat /var/jenkins_home/secrets/initialAdminPassword`
  - you can also access this password on the host since jenkins data is being replicated on the mount path we specified during the installation.
    - `docker volume inspect jenkins_home` will show you the mount path: "/var/lib/docker/volumes/jenkins_home/_data"

- there are two roles for Jenkins users:
  - jenkins admin:
    - administers and manages jenkins
    - sets up jenkins cluster
    - installs plugins
    - backup jenkins data
  - jenkins user
    - developer or devops teams
    - creating the actual jobs to run workflows

- __Install Node on the container where Jenkins is running:__
  - 
  - You can use plugins like with Maven. However, installing directly on the server gives you more flexibility because plugins only give you pre-configured options to work with.
  - The curl command used to install NodeJS on the Jenkins server is:
    - `curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh`
  - enter as root and complete docker installation
      - `docker exec -u 0 -it <container ID> bash`
        - -u flag: user
        - 0: represents the root user
      - to check the linux distribution information can be found at /etc/issue. This is helpful for making sure you install the right version of tools that are compatible with your container.
        - `cat /etc/issue`
      - `apt update`
      - `apt install curl`
      - `curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh`: installs node and npm
        - `bash nodesource_setup.sh`: execute the script
        - `apt install nodejs`
        - `node -v ; npm -v`

- __Freestyle Job:__
  - 
  - The most basic job type in jenkins
  - It is straightforward to setup and cinfigure. Suitable for simple, small scale projects
  - Not for use in production

- to see jobs in the container you can exec into the container and:
  - `ls /var/jenkins_home/jobs`
- to see the volumes on the host:
  - `docker volume ls`
- create a new container and attach the old volumes so that we do not lose any of the data we already have:
  - first stop the old container: `docker stop <containerID>`
  - `docker run -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts`
  - `docker ps`
- exec into the container as a root user: 
  - `docker exec -u 0 -it 9e5ed2146193 bash`
  - install docker so it can execute inside the container:
    `curl https://get.docker.com/ > dockerinstall && chmod 777 dockerinstall && ./dockerinstall`
- set the right permissions on the docker.sock file
  - docker.sock file is a Unix socket file, used by the Docker Daemon to communicate with the Docker client
  - `chmod 666 /var/run/docker.sock`
- Now you can exit and log back in as Jenkins user. You should now run docker commands without issue

- add docker username and password to Jenkins UI
- then configure the credentials under: Build env.> Bindings(username and password(separated)).
  - define the userrname variable and password variable you would like t use and then chose the credentials you provided earlier for docker hub
- execute shell
```
docker build -t jphyllisn/jma:jma-1.0 .
docker login -u $USERNAME -p $PASS
docker push phyllisn/jma:jma-1.0
```
- Change the docker login to a more secure practice, parse in the password as standard input:

```
docker build -t phyllisn/jma:jma-1.1 .
echo $PASS | docker login -u $USERNAME --password-stdin
docker push phyllisn/jma:jma-1.1
```
- __Pushing Docker Image from Jenkins to Nexus Repository:__
  - 
  - Because the Nexus repo is an http link, we have to configure the insecure registry in Jenkins as well: 
  - create `/etc/docker/daemon.json` file in the Docker host, not in the Jenkins container:
    - daemon.json file is a configuration file used by the Docker daemon to specify various settings to customize the behavior and functionality of the docker daemon according to your specific needs.
    ```
    {
    "insecure-registries":["<Nexus-server-ip>:8083"]
    }
    ```
  - restart docker to apply these changes
    - `sudo systemctl restart docker`
    - this stops all the containers. 
    - restart the containers with the `docker start <containerID>` command
    - reconfigure the permission to the docker.sock file
      - `docker exec -u 0 -it <containerID> bash` 
      - `chmod 666 /var/run/docker.sock`
  - configure nexus credentials in Jenkins UI
    - manage jenkins> credentials
    - then configure this in the java-maven-build job:
      - under bindings, choose the new nexus repo credentials
  - under execute shell tag the new image with the nexus repo:
  ```
  docker build -t 15.222.250.136:8083/jma:1.2 .
  echo $PASS | docker login -u $USERNAME --password-stdin 15.222.250.136:8083
  docker push 15.222.250.136:8083/jma:1.2
  ```
- __Pipeline:__
  - 
- __groovy sandbox:__
  - security feature that provides a restricted execution environment
  - you can execute a limited number of groovy functions, without needing approval from a Jenkins admin
- __Differences between Scripted and Declarative pipelines:__
  - Scripted:
    - first syntax
    - groovy engine
    - advanced scripting capabilities,
      - high flexibility- no predefined structure
    - difficult to start
    - Starts with 'node'
  - Declarative:
    - more recent addition
    - easier to get started, but not that powerful
    - pre-defined structure
    - Starts with 'pipeline'
  - declarative pipeline syntax:
  ```
  pipeline {
    agent any
      stages {
        stage("build") {
          steps {

          }
        }
      }
  }
  ```
- __Jenkins Environmental Variables:__
  - 
  - found at <Jenkins-server>:8080/env-vars.html

- __MultiBranch Pipeline:__
  - 
  - branch sources > behaviours > discover branches
  - branch-based logic for Multibranch pipeline:

- __credentials in Jenkins:__
  - 
  - "credentials plugin: Jenkins offers this plugin to store and manage credentials centrally
  - __scope:__
    - system(Jenkins and nodes only): credential is available only on the Jenkins server
      - not visible by or available for Jenkins Jobs
      - use case: used by jenkins admins for configuring/intergrating Jenkins with other Services
    - global(Jenkins, nodes, items, all child items, etc): accessible everyhere.
    - project: credentials that are limited to your project. 
      - Only in the multibranch pipeline
      - comes from the folder plugin
        - folder plugin: basically for organizing your jobs in folders. enables you to have credentials scoped to your project
  _ __credential types:__
    - username & password
    - secret file
    - secret text
    - Certificate
    - SSH username with private key
    - Github App
    - ohter new types based on plugins ... e.g. github app
  - __ID:__ reference for your credentials
- __Shared Library:__
  - 
  - main folder is called vars. it icludes all the functions that we execute or call from the Jenkinsfile
    - each function/execution step is its own groovy file inside the vars folder
  - src folder: helper code
    - where we can have any helper logic like utility code for the functions in the vars folder
  - resources folder: allows you to use external libraries for non-groovy files
    - Will contain any PowerShell shell scripts, SQL scripts, json files, etc.
  - make the  shared library available globally with:
    - Manage Jenkins > System > Global pipeline libraries
    - default version: default version of the library to load if a script does not select another.
      - can be a branch name, commit hash, tag, etc., according to the SCM
- __triggering Jenkins jobs:__
  - manually: use case- may be used for production pipelines
  - automatically: trigger automatically when changes happen in the git repository
  - scheduling: cron jobs. trigger job at scheduled times. e.g. running long tests, running tasks on schedule
  - install gitlab plugin
  - then configure system:
    - manage Jenkins > system > gitlab
    - give the connection a name, 
    - create an API token in gitlab (under profile > preferences> access tokens)then add that token in the jenkins credentials
  - configure Jenkins to build whenever there is a code change in gitlab
    - project > settings > integrations > jenkins
  - for multi-branch, you need another plugin: mutlibranch scan webhook trigger
    - in gitlab, configure webhook:
      - settings > webhooks

- __Dynamically Increment Application Version in Jenkins Pipeline:__
  - 
  - __incrementing maven (pom.xml)__
    - change the patch:
      - `mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion}`
    - change the major version:
      - `mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.nextMajorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion}`
    - change the minor version:
      - `mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.nextMinorVersion}.\${parsedVersion.incrementalVersion}`
    - replace pom.xml with the new version: you can use this logic in the Jenkinsfile
      - `mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion} versions:commit`
  - `mvn package` builds a jar file with version from pom.xml
  - `mvn clean package`: cleans(removes) the target folder before creating a new package
  - adding the version change details to be committed to the git reposistory creates an infinite loop of commit and webhook trigger.
    - when to configure logic that detect that the commit was made from Jenkins and ignore trigger when commit is from Jenkins
    - we can do it through a plugin: Ignore Committer Strategy. you can also use (depending on your git repository):
      - GitHub/Bitbucket Commit Skip SCM Behavior
      - configure multibranch pipeline
        - property strategy > build strategies > ignore committer stategy (jenkins email) > allow builds when a changeset contains non-ignored authors

__References:__
  - 
  - https://docs.google.com/document/d/16b3bCnW_dv52KiN5PALDt2AY6dOUCk2dgndjsAeWte4/edit
  - java-maven-app code source: 
    - https://gitlab.com/twn-devops-bootcamp/latest/08-jenkins/java-maven-app.git