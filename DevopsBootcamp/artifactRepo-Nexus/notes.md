# Nexus

- What is an artifact repository?
- __artifacts:__
  - applications built into a single shareable and easily movable file
  - it can have different formats: .jar, .war, .zip, .tar etc.
- An __artifact repository__ is where you store these files/artifacts
  - the artifact repository would have to support the specific format of artifact you are trying to store in it
- Features of repo manager:
  - integrate with LDAP
  - flexible and powerful REST API for integration with other tools
  - backup and restore
  - multi-format support (different file types- zip, tar, docker, etc.)
  - metadata tagging (labelling and tagging artifacts)
  - cleanup policies e.g. automatically deleting files that match a condition... like older than 30 days, etc.
  - search functionality across projects and repositories
  - user token support for system user (non human user) authentication
- __Install Nexus:__
  - `sudo -i`
  - `cd /opt`
  - <https://help.sonatype.com/repomanager3/product-information/download>
    - `wget <latest version of nexus- unix archive>`
  - untar file:
    - `tar -zxvf <tar file>`
      - this will untar two files:
        - __nexus folder:__ contains runtime and nexus application
        - __sonatype-work:__ contains your own config for nexus and data
          - it has subdirectories depending on your Nexus config. eg. when you install plugins they will create their own directories in this folder
          - it also has a list of all the IP addresses that acccesed Nexus
          - nexus app logs
          - your apploaded files and metadata
          - You can also use this folder for backup
- __Starting Nexus:__
  - services should not run with root user permissions
  - __Best Practice:__ Create own user for service (e.g. Nexus)
  - Grant the Nexus user only the permissions for that specific service
  - `adduser nexus`
  - currently, the nexus executable and sonatype-work folders are owned by root.
    - nexus needs to be able to access both these files.
      - `chown -R nexus:nexus nexus-3.63.0-01`
      - `chown -R nexus:nexus sonatype-work`
  - set Nexus configuration, so it will run as a Nexus user
    - `vim nexus-3.63.0-01/bin/nexus.rc`
    - uncomment and add user: run_as_user="nexus"
  - switch to nexus user and run the service as nexus user and start nexus service:
    - `su - nexus`
    - `/opt/nexus-3.63.0-01/bin/nexus start`
  - open firewall port 8081
  - now you can access nexus on the browser: `<public-ip>:8081`
  - nexus creates a default password when it creates the nexus user:
    - `cat /opt/sonatype-work/nexus3/admin.password`
    - username: admin
    - password: the password you copied above
    - change password
    - enable anonymous users
    - complete setup
- __Repository Types:__
  - __Proxy repository:__ a repository that is linked to a remote repository
    - e.g. maven-central, nuget.org-proxy
    - proxy repo is a link to the specified remote repo. e.g. If a component is requested from the remote repo by your app, like when you are trying to download a lib with a specific version from Maven Central, it will go through the proxy instead of directly to the remote and first check whether that component is available locally on Nexus/company nexus; if it is available, you application will take it from nexus. If it is not available, the request will be forwarded to the remote repository.
    - the component will then be retrieved from the remote and stored locally in Nexus, so Nexus will act as a cache; so the next request that needs the same component, it will go through Nexus and see the cached dependency, and it will not need to go pull from the remote repository.
    - advantages:
      - saves the network bandwidth and time for retrieving components from remote on every request
      - gives a developer a single repository entrypoint
  - __Hosted Repository:__ a repository that is the primary storage for artifacts and components.
    - e.g. maven releases, nuget-hosted, maven-snapshots
    - use case: company owned components, everything developed within the company, all the apps, artifacts are stored in nexus hosted repo.
    - Java app in development and testing, the release goes in maven-snapshots. When the code is ready for production, the release is stored in maven-releases.
    - maven-releases is intended to be the repo where your organization publishes internal releases.
      - you can also use this repo for third-party compnents that are not available in public or external repositories and can therefore not be retrieved via proxy repository.
      - e.g. commercial libraries, some proprietary libraries like Oracle, JDBC driver that may be referenced by your org, that are not externally available.
      - so you can create a proxy to fetch directly from them, but you can host it on this hosted repo as a company internal component, even though it's a third party lib dependency for your apps.
    - maven-snapshots is intended to be where your company publishes internal development versions.
      - These internal development versions are also called snapshots.
  - __Group Repository:__ This type of repository allows you to combine multiple repos and even other repo groups in a single repo
    - e.g. maven-public, nuget-group
    - this repo allows developer teams to use a single URL for their application, which will give them access to multiple repos at once, instead of working with mutiple URLs for each repo.
- __Publish Artifact to Repo__
  - Links to projects:
    - Java Gradle App: <https://gitlab.com/twn-devops-bootcamp/latest/06-nexus/java-app>
    - Java Maven App: <https://gitlab.com/twn-devops-bootcamp/latest/06-nexus/java-maven-app>
  - create a nexus user on nexus:
    - security > users > create local user
  - create a role for the nexus user:
    - Roles bring together multiple privileges so that, when you assign a user to the role, that user will automatically have all of those privileges. Roles can comprise both other roles and individual privileges.
    - grant the user view-* permissions
  - Grant that new role you just created to the nexus user and revoke the nx-anonymous role.
  - ** for gradle you configure user and pass in gradle.properties

    ```gradle.properties
     repoUser = phyllis
     repoPassword = xxxxxxx  
    ```

  - `gradle build`
  - `gradle publish`
  - ** for maven you configure repo user and password in ~/.m2 folder
    - `touch ~/.m2/settings.xml`: this is a file where maven's global credentials can be defined

    ```settings.xml
    <settings>
      <servers>
        <server>
          <id>nexus-snapshots</id>
          <username>phyllis</username>
          <password>xxxxxx</password>
        </server>
      </servers>
    </settings>
    ```

    - `mvn package`: build the artifact
    - `mvn deploy`: upload the artifact to the nexus repo
- __Nexus API:__
  - How to access the REST endpoint:
    - use a tool like `curl` or `wget` to execute HTTP request
    - provide user and  credential of a nexus user
    - use the nexus with the required permissions
  - query the repos:
    - `curl -u <username>:<pswd> -X GET 'http://35.183.29.205:8081/service/rest/v1/repositories'`
      - `curl -u admin:xxxxx -X GET 'http://35.183.29.205:8081/service/rest/v1/repositories'`
      - `curl -u phyllis:xxxxx -X GET 'http://35.183.29.205:8081/service/rest/v1/repositories'`
  - query all the components from a certain repository:
    - `curl -u <username>:<pswd> -X GET 'http://35.183.29.205:8081/service/rest/v1/components?repository=maven-snapshots'`
      - `curl -u admin:xxxxx -X GET 'http://35.183.29.205:8081/service/rest/v1/components?repository=maven-snapshots'`
      - `curl -u phyllis:xxxxx -X GET 'http://35.183.29.205:8081/service/rest/v1/components?repository=maven-snapshots'`
    - `curl -u <username>:<pswd> -X GET 'http://35.183.29.205:8081/service/rest/v1/components?repository=maven-releases'`
  - query one specific component and all its assets:
    - id is unique across components
    - `curl -u <username>:<pswd> -X GET 'http://35.183.29.205:8081/service/rest/v1/components/<id>'`
- __Blob Store:__
  - What is a blob store?
    - The binary assets you download via proxy repositories, or publish to hosted repositories, are stored in the blob store attached to those repositories. In traditional, single node NXRM deployments, blob stores are typically associated with a local filesystem directory, usually within the sonatype-work directory.
    - This is what Nexus uses to manage the storage per repo for all its components
    - the blob store is an internal storage mechanism for binary parts of artifacts.
    - it can be on the local file system or on a cloud server where nexus is deployed or cloud storage like Amazon S3
    - cannot delete the default blob store when it is in use by another repositories
    - you can create your own blob stores per repo or you can share one blob store among many repos
    - location: `/opt/sonatype-work/nexus3/blobs`
    - all data is in the `/opt/sonatype-work/nexus3/blobs/default/content` folder
    - blob store - type
      - type field: storage backend
        - file represents a file system-based storage
          - this is the default
          - recommended for most installations
        - S3 represents a cloud-based storage
          - only recommended for a nexus repo manager that is installed or deployed on AWS
    - blob store - state
      - state field: state of the blob store
        - started: indicates it is running as expected
        - failed: indicated a configuration issue: failed to initialize
    - blob store -  blob count
      - represents the number of blobs stored
      - in the `/opt/sonatype-work/nexus3/blobs/default/content` folder, you can see that the data is stored in different volumes or blobs and this is the number of blobs that is currently stored
    - create a blob store:
      - the path parameter: absolute path to the desired file system location
        - it has to be fully accessible by the OS user account (Nexus user)
      - __To Note:__
        - Once a blob store has been created, it cannot be modified!
        - A blob store used by a repo cannot be deleted!
        - Hence: you need to decide;
          - how many blob stored need to be created
          - with which sizes- you need to know approximately how much space each repo will need
          - which blob stores for which repos
        - blob stores can be moved from one storage device to another but they cannot be split and one repository cannot use multiple blob stores
- __Component vs. Asset:__
  - component: top-level folders
    - an abstract high level definition of what we are uploading
  - asset: the subdirectories under the components
    - the actual physicial packages/files
    - 1 component = 1 or more assets
  - Docker format gives assets unique identifiers and calls them __docker layers__
    - these layers are individual assets
    - and these assets can be reused for different components
    - e.g. 2 docker images that have two components that share the same assets
  - In Nexus, the term "component" is used to refer to any type or format of package that you upload to the repository
- __Cleanup Policies and Scheduled Tasks:__
  - cleanup policies help you decide the rules that will clean up artifacts, the components from the repo, either when they are too old or haven't been used for a long time, etc., in order to free up storage for newer components
  - Cleanup policies can be used to remove content from your repositories. These policies will execute at the configured frequency.
  - Always preview the repositories that you have configured to be deleted before creating the cleanup policies, so you don't accidentally delete a repository since you are configuring the cleanup policies for Nexus globally
  - __attach policy to repo:__
    - Once created, a cleanup policy must be assigned to a repository from the repository configuration screen.
    - a cleanup policy can be attached to multiple repos
  - __configuring on cleanup policy:__
    - under system > tasks
    - once you attach the clean up policy to a repo, it automatically creates a task to do so
    - you can also create your own tasks under system
    - __soft delete:__ with cleanup policies and cleaning up components from a repo they do not actually delete, they will be marked for deletion
      - to actually delete the items, you need to compact the blob store
      - choose the task frequency: The frequency this task will run.
        - Manual - this task can only be run manually.
        - Once - run the task once at the specified date/time.
        - Daily - run the task every day at the specified time.
        - Weekly - run the task every week on the specified day at the specified time.
        - Monthly - run the task every month on the specified day(s) and time.
        - Advanced - run the task using the supplied cron string.
    - you can also manually run the clean-up policy and compact the blob store instead of waiting for the cron to kick in
