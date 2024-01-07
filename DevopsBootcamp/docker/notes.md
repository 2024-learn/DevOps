# Docker
  - popular container technologies: Docker, cri-o, containerd
  - __container vs image__: 
    - ref: https://aws.amazon.com/compare/the-difference-between-docker-images-and-containers/
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
      - container is made up of layers of images, and a mostly linux base image(alpine), because of their small size
        - the advantage of the layers is that if you need to pull another container, e.g. a newer version of the postgres container, only the different layers are downloaded.
      - A Docker container is a self-contained, runnable software application or service
      - containers are mutable and allow modificatins during runtime
      - A runtime instance; a self-contained software.
      - created from an image. it is a running environemnt for an image or a running instance of an image
      - Read-only layers with an additional read-write layer on top.
      - when to use: To run the application.
- __Docker Architecture__
  - 
  - When you install docker, you install a docker engine which is made up of three parts: 
    - __docker server:__ responsible fot pulling images, storing them, starting containers stopping containers, etc.
      - it has the following functionalities:
        - __container runtime:__ the part actually responsible for pulling images, maintaining container lifecycle
        - __volumes:__ responsible for persisiting data in containers
        - __network:__ responsible for configuring network for container communication
        - __build images:__ build own docker images
    - __docker API:__ which is an APi for interacting with the docker server
    - __docker CLI:__ the command line interface of Docker to execute docker commands
  - There are other options for some of docker's functionalities. Container runtime tools like containerd and cri-o which you can use if you only need a container runtime on a server to run images, including docker images.
  - there also tools that allow you to build container images like Buildah

- __Main Docker Commands:__
  - 
  - A container is a running environment for an image
    - it contains a virtual file system, environemntal configurations and the aplication image
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
        ```
        aa06b6fe1d59   redis:6.2   "docker-entrypoint.s…"   5 seconds ago        Up 5 seconds        0.0.0.0:6001->6379/tcp   competent_blackwell
        94a470da7669   redis       "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:6000->6379/tcp   suspicious_mcclintock
        ```
  - `docker logs <container id or name>`: displays the logs of the specified container
    - `docker logs | tail `: shows the last few logs from the container
    - `docker logs <container name or id>` -f: streams the container logs
  - `docker run -d -p <host port>:<container port> --name <name> <image>`: creates a container with our own specified name with the `--name` flag
    - `docker run -d -p 6002:6379 --name redis-older redis:6.2`
      - 5c2d0bd91d0a   redis:6.2   "docker-entrypoint.s…"   7 seconds ago    Up 7 seconds    0.0.0.0:6003->6379/tcp   __redis-older__
  - `docker exec -it`: used to get the terminal of a running container
    - `-it` flag stands for interactive ternminal
    - `docker exec -it <container id> or <container name> /bin/bash`
    - `exit` to get out of the interactive terminal of the container
- __demo project:__
  - source code from: https://gitlab.com/twn-devops-bootcamp/latest/07-docker/js-app.git
  - to start the app: 
    - `npm install`: to install the dependencies
    - `node server.js`: to start the application
  - pull mongo and mong0-express images
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
    ```
    docker run -p 27017:27017 -d -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=password --name mongodb --net mongo-network mongo
    ```
  - start mongo-express container:
    ```
    docker run -d -p 8081:8081 -e ME_CONFIG_MONGODB_ADMINUSERNAME=admin -e ME_CONFIG_MONGODB_ADMINPASSWORD=password --net mongo-network --name mongo-express-e ME_CONFIG_MONGODB_SERVER=mongodb mongo-express
    ```
- __Docker Compose:__
  -   
  - abstracts aways the low-level docker commands
  - provides a higher level, more readable configuration format
- docker-compose.yaml
    ```
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
    - spcecify dependencies and relationshis between service to ensure proper communication and required services are started in the correct order
    - `restart: always`: always restart the container if it stops
      - make sure MongoExpress can connect to MongoDB container, in case the mongo-express container was to be created before the mongodb container, it would keep restarting until the latter container was created and mongo-express can connect to it
    - `depends_on`:
      - expresses startup and shutdown dependencies between services
  - docker compose is installed with docker
  - `docker-compose -f docker-compose.yaml up`
  - data persistence with containers: data is lost on recreation
    - docker volumes: enables persisting data generated and used by docker containers
- __dockerfile__
  - 
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




- __References:__
  - 
  - MongoDB Docker Image: https://hub.docker.com/_/mongo
  - Mongo Express Docker Image: https://hub.docker.com/_/mongo-express
  - Docker compose installation guide:
    - https://doc.docker.com/compose/install
  - Amazon ECR Docker Registry: 
    - https://aws.amazon.com/ecr
  - Installing AWS Cli Linux:
    - https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
  - Installing AWS CLI on MacOS: 
    - https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-macOS.html
  - Installing AWS CLI on Windows:
    - https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html
  - Configuring the AWS CLI:
    - https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
  - Nexus Docker Image:
    - https://hub.docker.com/r/sonatype/nexus3
  - Best practices for writing Dockerfiles:
    - https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
  - Docker development best practices:
    - https://docs.docker.com/develop/dev-best-practices/
  - Tips for Caching, reducing Image size, maintainability, reproducibility:
    - https://www.docker.com/blog/intro-guide-to-dockerfile-best-practices/
  - Tip: Enforce Dockerfile best practices automatically by using a static code analysis tool (e.g. https://github.com/hadolint/hadolint )
  - 

