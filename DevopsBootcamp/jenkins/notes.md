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
  - The following variables are available to shell and batch build steps:
    - BRANCH_NAME
      - For a multibranch project, this will be set to the name of the branch being built, for example in case you wish to deploy to production from master but not from feature branches; if corresponding to some kind of change request, the name is generally arbitrary (refer to CHANGE_ID and CHANGE_TARGET).
    - BRANCH_IS_PRIMARY
      - For a multibranch project, if the SCM source reports that the branch being built is a primary branch, this will be set to "true"; else unset. Some SCM sources may report more than one branch as a primary branch while others may not supply this information.
    - CHANGE_ID
      - For a multibranch project corresponding to some kind of change request, this will be set to the change ID, such as a pull request number, if supported; else unset.
    - CHANGE_URL
      - For a multibranch project corresponding to some kind of change request, this will be set to the change URL, if supported; else unset.
    - CHANGE_TITLE
      - For a multibranch project corresponding to some kind of change request, this will be set to the title of the change, if supported; else unset.
    - CHANGE_AUTHOR
      - For a multibranch project corresponding to some kind of change request, this will be set to the username of the author of the proposed change, if supported; else unset.
    - CHANGE_AUTHOR_DISPLAY_NAME
      - For a multibranch project corresponding to some kind of change request, this will be set to the human name of the author, if supported; else unset.
    - CHANGE_AUTHOR_EMAIL
      - For a multibranch project corresponding to some kind of change request, this will be set to the email address of the author, if supported; else unset.
    - CHANGE_TARGET
      - For a multibranch project corresponding to some kind of change request, this will be set to the target or base branch to which the change could be merged, if supported; else unset.
    - CHANGE_BRANCH
      - For a multibranch project corresponding to some kind of change request, this will be set to the name of the actual head on the source control system which may or may not be different from BRANCH_NAME. For example in GitHub or Bitbucket this would have the name of the origin branch whereas BRANCH_NAME would be something like PR-24.
    - CHANGE_FORK
      - For a multibranch project corresponding to some kind of change request, this will be set to the name of the forked repo if the change originates from one; else unset.
    - TAG_NAME
      - For a multibranch project corresponding to some kind of tag, this will be set to the name of the tag being built, if supported; else unset.
    - TAG_TIMESTAMP
      - For a multibranch project corresponding to some kind of tag, this will be set to a timestamp of the tag in milliseconds since Unix epoch, if supported; else unset.
    - TAG_UNIXTIME
      - For a multibranch project corresponding to some kind of tag, this will be set to a timestamp of the tag in seconds since Unix epoch, if supported; else unset.
    - TAG_DATE
      - For a multibranch project corresponding to some kind of tag, this will be set to a timestamp in the format as defined by java.util.Date#toString() (e.g., Wed Jan 1 00:00:00 UTC 2020), if supported; else unset.
    - JOB_DISPLAY_URL
      - URL that will redirect to a Job in a preferred user interface
    - RUN_DISPLAY_URL
      - URL that will redirect to a Build in a preferred user interface
    - RUN_ARTIFACTS_DISPLAY_URL
      - URL that will redirect to Artifacts of a Build in a preferred user interface
    - RUN_CHANGES_DISPLAY_URL
      - URL that will redirect to Changelog of a Build in a preferred user interface
    - RUN_TESTS_DISPLAY_URL
      - URL that will redirect to Test Results of a Build in a preferred user interface
    - CI
      - Statically set to the string "true" to indicate a "continuous integration" execution environment.
    - BUILD_NUMBER
      - The current build number, such as "153".
    - BUILD_ID
      - The current build ID, identical to BUILD_NUMBER for builds created in 1.597+, but a YYYY-MM-DD_hh-mm-ss timestamp for older builds.
    - BUILD_DISPLAY_NAME
      - The display name of the current build, which is something like "#153" by default.
    - JOB_NAME
      - Name of the project of this build, such as "foo" or "foo/bar".
    - JOB_BASE_NAME
      - Short Name of the project of this build stripping off folder paths, such as "foo" for "bar/foo".
    - BUILD_TAG
      - String of "jenkins-${JOB_NAME}-${BUILD_NUMBER}". All forward slashes ("/") in the JOB_NAME are replaced with dashes ("-"). Convenient to put into a resource file, a jar file, etc for easier identification.
    - EXECUTOR_NUMBER
      - The unique number that identifies the current executor (among executors of the same machine) that’s carrying out this build. This is the number you see in the "build executor status", except that the number starts from 0, not 1.
    - NODE_NAME
      - Name of the agent if the build is on an agent, or "built-in" if run on the built-in node (or "master" until Jenkins 2.306).
    - NODE_LABELS
      - Whitespace-separated list of labels that the node is assigned.
    - WORKSPACE
      - The absolute path of the directory assigned to the build as a workspace.
    - WORKSPACE_TMP
      - A temporary directory near the workspace that will not be browsable and will not interfere with SCM checkouts. May not initially exist, so be sure to create the directory as needed (e.g., mkdir -p on Linux). Not defined when the regular workspace is a drive root.
    - JENKINS_HOME
      - The absolute path of the directory assigned on the controller file system for Jenkins to store data.
    - JENKINS_URL
      - Full URL of Jenkins, like http://server:port/jenkins/ (note: only available if Jenkins URL set in system configuration).
    - BUILD_URL
      - Full URL of this build, like http://server:port/jenkins/job/foo/15/ (Jenkins URL must be set).
    - JOB_URL
      - Full URL of this job, like http://server:port/jenkins/job/foo/ (Jenkins URL must be set).
    - GIT_COMMIT
      - The commit hash being checked out.
    - GIT_PREVIOUS_COMMIT
      - The hash of the commit last built on this branch, if any.
    - GIT_PREVIOUS_SUCCESSFUL_COMMIT
      - The hash of the commit last successfully built on this branch, if any.
    - GIT_BRANCH
      - The remote branch name, if any.
    - GIT_LOCAL_BRANCH
      - The local branch name being checked out, if applicable.
    - GIT_CHECKOUT_DIR
      - The directory that the repository will be checked out to. This contains the value set in Checkout to a sub-directory, if used.
    - GIT_URL
      - The remote URL. If there are multiple, will be GIT_URL_1, GIT_URL_2, etc.
    - GIT_COMMITTER_NAME
      - The configured Git committer name, if any, that will be used for FUTURE commits from the current workspace. It is read from the Global Config user.name Value field of the Jenkins Configure System page.
    - GIT_AUTHOR_NAME
      - The configured Git author name, if any, that will be used for FUTURE commits from the current workspace. It is read from the Global Config user.name Value field of the Jenkins Configure System page.
    - GIT_COMMITTER_EMAIL
      - The configured Git committer email, if any, that will be used for FUTURE commits from the current workspace. It is read from the Global Config user.email Value field of the Jenkins Configure System page.
    - GIT_AUTHOR_EMAIL
      - The configured Git author email, if any, that will be used for FUTURE commits from the current workspace. It is read from the Global Config user.email Value field of the Jenkins Configure System page.

__References:__
  - 
  - https://docs.google.com/document/d/16b3bCnW_dv52KiN5PALDt2AY6dOUCk2dgndjsAeWte4/edit
  - java-maven-app code source: 
    - https://gitlab.com/twn-devops-bootcamp/latest/08-jenkins/java-maven-app.git