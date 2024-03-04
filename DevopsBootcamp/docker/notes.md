# Docker

- popular container technologies: Docker, cri-o, containerd
  - __container vs image__:
    - ref: <https://aws.amazon.com/compare/the-difference-between-docker-images-and-containers/>
    - __image:__
      - the actual application package together with the configuration and dependencies
      - it is a portable artifact that is easily shared and moved around
      - images are immutable. if a change needs to be made, you must create a new image with the desired modifications.
        - A reusable, shareable file used to create containers.
        - Created from software code, dependencies, libraries, and a Dockerfile.
      - Read-only layers.
      - a docker image is the template loaded onto the container to run it, like a set of instructions.
      - when to use: To store application configuration details as a template.
    - __container:__
      - a container is a portable way to package an application along with all its dependencies and the necessary configuration
      - container is made up of layers of images, and a mostly linux base image(alpine), because of their small size
        - the advantage of the layers is that if you need to pull another container, e.g. a newer version of the postgres container, only the different layers are downloaded.
      - A Docker container is a self-contained, runnable software application or service
      - containers are mutable and allow modifications during runtime
      - A runtime instance; a self-contained software.
      - created from an image. it is a running environment for an image or a running instance of an image
      - Read-only layers with an additional read-write layer on top.
      - when to use: To run the application.
- __Docker Architecture__
  - When you install docker, you install a docker engine which is made up of three parts:
    - __docker server:__ responsible for pulling images, storing them, starting containers, stopping containers, etc.
      - it has the following functionalities:
        - __container runtime:__ the part actually responsible for pulling images, maintaining container lifecycle
        - __volumes:__ responsible for persisiting data in containers
        - __network:__ responsible for configuring network for container communication
        - __build images:__ build own docker images
    - __docker API:__ which is an API for interacting with the docker server
    - __docker CLI:__ the command line interface of Docker to execute docker commands
  - There are other options for some of docker's functionalities. Container runtime tools like containerd and cri-o which you can use if you only need a container runtime on a server to run images, including docker images.
  - there also tools that allow you to build container images like Buildah

- __Main Docker Commands:__
  - A container is a running environment for an image
    - it contains a virtual file system, environmental configurations and the aplication image
    - port binding: makes it possible to talk to application running inside the container
  - `docker pull <image>`: pulls image from remote repo
  - `docker images`: lists all images
  - __docker tags:__ After the image name, the optional TAG is a custom, human-readable manifest identifier that is typically a specific version or variant of an image. The tag must be valid ASCII and can contain lowercase and uppercase letters, digits, underscores, periods, and hyphens. It cannot start with a period or hyphen and must be no longer than 128 characters. If the tag is not specified, the command uses latest by default.
  - `docker run [options] IMAGE [command] [ARGs...]`: pulls image and starts a new container
    - `docker run -e POSTGRES_PASSWORD=mysecretpassword postgres:13.10`
    - `docker run`: fetches the container from a remote repo is it is not available locally and starts it
    - docker run starts the container in the terminal in an attached mode
    - `docker run -d redis`: the `-d` flag helps the container run in a detached mode
  - `docker ps`: lists all the running containers
    - `docker ps -a`: lists all stopped and running containers
  - `docker stop <container id>`: stops the container
  - `docker start <container id>`: restarts the stopped container
    - it works with containers unlike docker run which works with the image.
  - __container port vs. host port:__
    - The containerPort is the port where the application inside the container is running, and the hostPort is the port on the host node's network interface that this container port is mapped to.
    - __port binding to the host port:__
      - `docker run -p <host port>:<container port> <image>`
        - e.g. `docker run -p 6000:6379 -d redis`
      - so now when you run docker ps` again, it displays:
        - b14e90b6e1d8   redis     "docker-entrypoint.s…"   8 seconds ago   Up 7 seconds   __0.0.0.0:6000->6379/tcp__   youthful_keller
      - you can then have multiple instances of redis running and reacheable on the same host without an error that the port is already in use/conflicting ports as long as they are attached to different ports on the host:

        ``` conflicting ports
        aa06b6fe1d59   redis:6.2   "docker-entrypoint.s…"   5 seconds ago        Up 5 seconds        0.0.0.0:6001->6379/tcp   competent_blackwell
        94a470da7669   redis       "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:6000->6379/tcp   suspicious_mcclintock
        ```

  - `docker logs <container id or name>`: displays the logs of the specified container
    - `docker logs | tail`: shows the last few logs from the container
    - `docker logs <container name or id>` -f: streams the container logs
  - `docker run -d -p <host port>:<container port> --name <name> <image>`: creates a container with our own specified name with the `--name` flag
    - `docker run -d -p 6002:6379 --name redis-older redis:6.2`
      - 5c2d0bd91d0a   redis:6.2   "docker-entrypoint.s…"   7 seconds ago    Up 7 seconds    0.0.0.0:6003->6379/tcp   __redis-older__
  - `docker exec -it`: used to get the terminal of a running container
    - `-it` flag stands for interactive ternminal
    - `docker exec -it <container id> or <container name> /bin/bash`
    - `exit` to get out of the interactive terminal of the container
- __demo project:__
  - source code from: <https://gitlab.com/twn-devops-bootcamp/latest/07-docker/js-app.git>
  - to start the app:
    - `npm install`: to install the dependencies
    - `node server.js`: to start the application
  - pull mongo and mongo-express images
    - mongo-express: mongo-express is a web-based MongoDB admin interface written in Node.js, Express.js, and Bootstrap3.
    - `docker pull mongo`
    - `docker pull mongo-express`
- docker network:
  - docker creates its isolated docker network, where the containers are running in.
  - when you deploy two containers, they can talk to each other using just the container name, without localhost, port number...etc because they are in the same network
  - applications running outside of docker can connect to the applications running in docker using localhost and the port number
  - `docker network ls`: lists docker networks
  - create a docker network: `docker network create mongo-network`
  - start mongo container:

    ``` start mongo container
    docker network create mongo-network 
    docker run -d -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=password --name mongodb --net mongo-network mongo    
    ```

  - start mongo-express container:

    ```start mongo-express
    docker run -d -p 8081:8081 -e ME_CONFIG_MONGODB_ADMINUSERNAME=admin -e ME_CONFIG_MONGODB_ADMINPASSWORD=password --net mongo-network --name mongo-express -e ME_CONFIG_MONGODB_SERVER=mongodb mongo-express  
    ```

    start the app:

    ``` start app
    docker run -d -p 3000:3000 --name node-app --net mongo-network phyllisn/my-app:1.3
    ```

- __Docker Compose:__
  - abstracts aways the low-level docker commands
  - provides a higher level, more readable configuration format
- docker-compose.yaml

    ```docker-compose.yaml
    version: '3' # version of docker compose
    services:   # container list
        mongodb:    # container name
            image: mongo
            ports:
                - 27017:27017   # host:container
            environment:    # environment variables
                - MONGO..._USERNAME=admin
        mongo-express:
            image: mongo-express
            ports:
                - 8081:8081
            environment:
                - ME_CONFIG_MONGODB_A...
                ...
    ```

  - docker compose helps to structure docker commands and simplifies container management
  - containers, networks, volumes and configuration using a YAML file
  - declarative approach: defining the desired state
  - by default, docker compose sets up a single network for your app so you don't have to specify the network in the file
    - but you do have the option to specify your own networks with the top-level "networks" key
  - __service orchestration with docker compose:__
    - specify dependencies and relationships between service to ensure proper communication and required services are started in the correct order
    - `restart: always`: always restart the container if it stops
      - make sure MongoExpress can connect to MongoDB container, in case the mongo-express container was to be created before the mongodb container, it would keep restarting until the latter container was created and mongo-express can connect to it
    - `depends_on`:
      - expresses startup and shutdown dependencies between services
  - docker compose is installed with docker
  - `docker-compose -f docker-compose.yaml up`
  - data persistence with containers: data is lost on recreation
    - docker volumes: enables persisting data generated and used by docker containers
- __Dockerfile__
  - blueprint for building images
  - It is a file containing a set of instructions to build a docker image
    - `FROM`: specifies the base image for the new image
    - `ENV`: sets the env. vars
    - `RUN`: allows you to execute any command within the linux container.
      - `RUN mkdir -p /home/app`: This directory is created inside of the container
      - commands apply to the container environment only
    - `COPY <src> <dest>`: copies file to the specified location
      - `COPY . /home/app`: executes on the host machine. copy current folder items on the host machine to /home/app in the docker container
    - `CMD []`: entrypoint command
      - `CMD ["node", "server.js"]`: starts the app with: `node server.js`
    - login to docker:
      - `docker login -u username -p password docker.io`
- __Private Docker Registry:__
  - install AWSCLI on macOS: <https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-macOS.html>
  - install Rosetta:
  - `sudo softwareupdate --install-rosetta`
  - `aws configure`: Login to AWS. Provide the AWS credentials
  - sign in to the AWS ECR: `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 137236605350.dkr.ecr.us-east-1.amazonaws.com`
  - Image naming in Docker registries:
    - registryDomain/imageName:tag
  - tag the image:
    - `docker tag my-app:1.0 137236605350.dkr.ecr.us-east-1.amazonaws.com/my-app:1.0`
    - `docker tag`: renames the image
  - push the images to the AWS registry:
    - `docker push 137236605350.dkr.ecr.us-east-1.amazonaws.com/my-app:1.0`

- __Docker Volume:__
  - on the host we have a physical file system: eg. /home/mount/data
  - on the container we have a virtual file system: eg. /var/lib/mysql/data
  - __volume types:__
    - __host volumes:__
      - where we define the connection or the reference between the host directory and the container directory
        - `docker run -v /home/mount/data:var/lib/mysql/data`
      - you decide where on the host file system the reference is made
    - __anonymous volumes:__
      - create a volume just by referencing the container directory
        - `docker run -v /var/lib/mysql/data`
      - the host directory where the volume should be mounted is not specified
      - for each container a folder is generated that gets mounted
    - __named volumes:__
      - It is an improvement on anonymous volumes.
        - `docker run -v name:/var/lib/mysql/data`
      - it specifies the name of the folder on the host file system
      - unlike anonymous volumes, you can reference this volume by name
      - recommended for use in production
      - reference in a docker-compose:

      ```named-volumes
      version: '3'
      services:
        mongodb:
          image: mongo
          ports:
            - 27017:27017
          volumes:
            - db-data:/var/lib/mysql/data   #define under which path the volume can be mounted
        mongo-express:
          ...
      volumes:
        db-data # list all the volumes that you have defined
      ```

      - advantage: you can mount a reference of the same folder on a host to more than one container, which is especially advantageous if those containers need to share data
      - To access the shell of the Docker VM in order to view volume information, use this command:
  - __Docker volumes demo:__
  - The actual storage path is created by docker itself. this information is for docker to create that storage on a local file system.

  ```volumes
  volumes:
  mongo-data:
    driver: local
  ```

  - once you have that name reference it can then be used in the container.
    - mapped out as: host-volume-name:path-inside-the-container
      - this has to be the path that mongodb persists data: /data/db
        - mysql path: /var/lib/mysql
        - postgress: /var/lib/postgresql/data

      ```volumes
      volumes:
        - mongo-data:/data/db
      ```

  - docker volume locations: /var/lib/docker/volumes
  - to view this on MacOs:
    - `docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh`
    - `ls /var/lib/docker/volumes`
- __docker hosted repository on nexus__
  - configure a docker hosted repo on nexus
  - HTTP: 8083
  - `cat ~/.docker/config.json`: it contains all the configuration changes ever made to docker
  - configure realm: Docker Bearer Token
  - deploy a plain http registry: <https://docker-docs.uclv.cu/registry/insecure/>
  - in the docker UI: settings > docker engine >
  - under experimental enter:
  - `"insecure-registries": ["<nexus-server external IP:8083>"],`
    - apply and restart docker
  - `docker login <external IP of nexus server:8083>`
  - the docker config.json got updated and now has the token that docker repo issued beck to our client, so now we don't have to login everytime we execute commands to the repository.
    - `cd js-app`
    - `docker build -t my-app:1.4 .`
    - `docker tag my-app:1.4 <external IP of nexus server:8083>/my-app:1.4`
      - e.g. `docker tag my-app:1.4 99.79.194.154:8083/my-app:1.4`
    - `docker push 99.79.194.154:8083/my-app:1.4`
    - fetch available docker images:
      - `curl -u <nexus-user>:<password> -X GET 'http://nexus-server-ip:8081/service/rest/v1/components?repository=docker-hosted'`
        - `curl -u nx-java:phyllis -X GET 'http://99.79.194.154:8081/service/rest/v1/components?repository=docker-hosted'`
- __Deploy Nexus as a Docker container:__
  - image: <https://hub.docker.com/r/sonatype/nexus3>
  - install docker on new server
    - `sudo apt-get update`
    - `sudo apt install docker.io`
    - `docker volume create --name nexus-data`
    - `docker run -d -p 8081:8081 --name nexus -v nexus-data:/nexus-data sonatype/nexus3`
    - `sudo apt install net-tools`
    - `netstat lpnt`
  - Nexus needs to be operated by a nexus user not root:
    - `docker ps`
    - `docker exec -it b1626ab34803 /bin/bash`
    - `whoami`
  - see where the data is persisted on the host machine:
    - `docker volume ls`
    - `docker inspect <name of the nexus volume>`
      - `docker inspect nexus-data`
        - This will provide a json output which has the mount point: `/var/lib/docker/volumes/nexus-data/_data`
        - `sudo ls /var/lib/docker/volumes/nexus-data/_data`
        - this has the admin.password
    - this data is also inside the container.
      - `docker exec -it b1626ab34803 /bin/bash`
      - `ls`
      - `cd ../../`
      - `ls nexus-data/`

- __Docker Best Practices:__
  - __Use official docker images as base image__

  - __Use a specific image version not the "latest" that way you do not get different docker image versions which might break stuff.__
    - Fixate the version

  - __Use a lighter version of the base image like Alpine__
    - images of full blown operating system distro might have more system utilities packaged, hence more tools but you do not need all that in a container. These images are heavier with more layers which beats the purpose of containerization which is light weight images.
    - full blown operating system distro images also have higher vulnerability exposures
    - lighter images means less storage space and you can transfer (push, pull) images faster
    - if you do not require any specific utilities in the container, choose leaner and smaller official images

  - __Optimize caching image layers__
    - Image layers: we create images using a dockerfile. each command creates a layer.
    - check docker layers in the image by:
      - `docker history my-app:1.4`
    - docker caches each layer, saved on the local file system. If nothing has changed in a layer (or any layers preceding it), it will be re-used from cache
    - once a layer changes, all the following layers are recreated as well. in other words, when you change one line in the Dockerfile, caches of all the following layers will be busted and invalidated, so each layer from that point will be rebuilt.
    - Order your commands in the Dockerfile from least to most frequently changing.
    - advantages of caching:
      - faster image building
      - downloading only added layers, therefore reducing network-bandwidth
    - e.g. optimize caching "npm install" layer. Do not re-run when project files change, re-run when package.json file changes
      |      Instructions           | Dockerfile                              |
      |-----------------------------|-----------------------------------------|
      | pull node alpine image      | FROM node:20.0.2-alpine                 |
      | set working directory       | WORKDIR /app                            |
      | copy package.json           | COPY package.json package-lock.json .   |
      | install dependencies        | RUN npm install --production            |
      | copy project files          | COPY myapp /app                         |
      | entrypoint command          | CMD ["node", "src/index.js"]            |

  - __Do not include everything in the Dockerfile. Exclude autogenerated folders(like target, build), README files, node_modules, ... etc.__
    - This helps to reduce the image size and prevent unintended secrets exposure
      - use a .dockerignore file to explicitly exclude files and folders
      - matching is done using Go's filepath.Match rules
      - e.g. .dockerignore

      ```.dockerignore
      # ignore .git amd .cache folders
      .git
      .cache
      # ignore all markdown files (md)
      *.md
      # ignore sensitive files
      private.key
      settings.json 
      ...
      ```

  - __You need to separate the "build" stage from the "runtime" stage by making use of multi-stage builds.__
    - There are contents needed during the building of the image that are not needed in the final image to run the app, like test dependencies, development tools, build tools(package.json, pom.xml) that are used for specifying project dependencies and needed for installing dependencies.
      - the multi-stage build feature allows you to use multiple temporary images during the build process and only keep the latest image as the final artifact
      - e.g. Dockerfile with 2 build stages.
        - you can name your stages with `AS <name>`
        - 1st stage: build java app
        - each FROM instruction starts a new build stage
        - you can selectively copy artifacts from one stage to another.
          - so here we are using files generated in the build stage to copy them in the final image.
          - the final application image is created only in the last stage. All the files and tools used in the first (build) stage will be discarded once it's completed

      ```multi-build
      # Build stage
      FROM maven AS build
      WORKDIR /app
      COPY myapp /app
      RUN mvn package

      # RUN stage
      FROM tomcat
      COPY --from=build /app/target/file.war /usr/local/tomcat/we...
      ...
      ```

  - __Create a least priviledged OS User that will be used to start the application__
    - by default, if you do not specify the user, Docker uses the root user.
      - This is a bad security practice because when the container starts on the host, it could potentially have root access on the Docker host granting an attacker easier priviledge escalation.
        - create a dedicated user and group in the docker image and don't forget to set required permissions
        - change to non-root user with USER directive:
        -e.g.:

      ```priviledged user
      ...
      # Create group and user
      RUN group add -r tom && useradd -g tom tom

      # Set ownership and permissions
      RUN chown -R tom:tom /app

      # Switch to user
      USER tom

      CMD ["node", "index.js"]
      ```

    - conveniently, some images like node.js already have a generic user bundled in(node), so you do not need to create one yourself.

      ```nodejs docker file
      FROM node:20.0.2-alpine
      WORKDIR /app
      COPY package.json package-lock.json .
      RUN npm install --production
      COPY myapp /app
      USER node
      CMD ["node", "src/index.js"]
      ```

  - __Scan the images for security vulnerabilities__
    - Docker uses its own service for the vulnerability scan.
      - Use Docker Scout:
        - `docker scout cves myapp:1.4`
      - In the background, docker used its own database of known vulnerabilities to run a can on the image.
        - The database of known vulnerabilites gets constantly updated

- __References:__
  - MongoDB Docker Image: <https://hub.docker.com/_/mongo>
  - Mongo Express Docker Image: <https://hub.docker.com/_/mongo-express>
  - Docker compose installation guide:
    - <https://doc.docker.com/compose/install>
  - Amazon ECR Docker Registry:
    - <https://aws.amazon.com/ecr>
  - Installing AWS Cli Linux:
    - <https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html>
  - Installing AWS CLI on MacOS:
    - <https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-macOS.html>
  - Installing AWS CLI on Windows:
    - <https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html>
  - Configuring the AWS CLI:
    - <https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html>
  - Nexus Docker Image:
    - <https://hub.docker.com/r/sonatype/nexus3>
  - Best practices for writing Dockerfiles:
    - <https://docs.docker.com/develop/develop-images/dockerfile_best-practices/>
  - Docker development best practices:
    - <https://docs.docker.com/develop/dev-best-practices/>
  - Tips for Caching, reducing Image size, maintainability, reproducibility:
    - <https://www.docker.com/blog/intro-guide-to-dockerfile-best-practices/>
  - Tip: Enforce Dockerfile best practices automatically by using a static code analysis tool (e.g. <https://github.com/hadolint/hadolint> )
  -
