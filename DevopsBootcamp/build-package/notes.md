# Building

- __Build tools and package managers for different programming languages__
| Language  | Built tools            |
|-----------|------------------------|
| Java      | maven/ gradle/ ant     |
| JavaScript| npm/yarn/ webpack      |
| Python    | pip                    |
| C/ C++    | conan                  |
| C#        | NuGet                  |
| Golang    | dep                    |
| Ruby      | RubyGems               |

- __Useful Links:__
- Maven Repository: <https://mvnrepository.com/>
- NPM Repository: <https://www.npmjs.com/package/repository>

- __examples of artifact repositories:__
  - Nexus, JFrog
  
- __Build tools in Java:__
  - __maven__
    - refs:
      - <https://jenkov.com/tutorials/maven/maven-commands.html>
      - <https://www.geeksforgeeks.org/maven-lifecycle-and-basic-maven-commands/>
    - uses xml
    - `mvn package`:
    - `mvn install`: installs dependencies, build the jar/war file and creates *target* file
    - dependencies are managed in *pom.xml*
    - Running the application:
      - `java -jar <>`
      - e.g. `java -jar target/java-maven-app-1.1.0-SNAPSHOT.jar`
  - __gradle__
    - refs:
      - <https://gist.github.com/jiffle/499caa5f53ab8f90dc19a3040ee40f48>
      - <https://spring.io/guides/gs/gradle/>
    - uses groovy
    - `gradle build`: installs the project dependencies, creates jar file and generated *build* file
    - dependencies are managed in *build.gradle*
    - Running the application:
    - `java -jar <path of the jar file>`
      - e.g. `java -jar build/libs/java-app-1.0-SNAPSHOT.jar`

  - both, maven and gradle, use the same dependency repository: <https://mvnrepository.com/>
  
  - How it works:
    - find a dependency with name and version
    - add it to the dependencies file (pom.xml)
    - the dependency gets downloaded locally (e.g local maven repo) so that it does not need to keep downloading it from the remote repo
    - locally the dependencies are in ~/.m2/repository folder
- __Build JS applications:__
  - No special artifact type. It has a zip or tar file
    - this includes the application code but not the dependencies.
    - there are additional modules for npm and yarn that will add this functionality to include dependencies in the artifact
    - so whenever you want to run that artifact on a server, you first have to install the dependencies then unpack the zip/tar file and run the application like you would locally.
    - you need to copy the artifact and package.json file
  - you can use either npm or yarn for package managers (they are not build tools)
    - they build dependencies, but they are not used for transpiling JS code
  - package.json for dependencies
  - `npm install`: installs all the dependencies that are defined in the package.json file and also generates a package-lock.json file
    - package.json file is equivalvent to pom.xml in maven and build.gradle in gradle
  - npm repository for dependencies: <https://npmjs.com>
  - CLI:
    - `npm start`: start the application
    - `npm stop`: stop the application
    - `npm test`: run the tests
    - `npm pack`: creates an artifact
    - `npm publish`: publish the artifact to the artifact repository
    - ...
  - Javascript is much more flexible. It is not as structured and standardized as Java
  - __package front-end code:__
    - you can package frontend and backend code separately
    - or you can have a common packagge for both
    - frontend/react code needs to be transpiled
    - browsers do not support latest JS versions or other fancy code decorations, like JSX
    - code also needs to be compressed/minified to make sure the code runs faster in the browser
      - separate tools for that- build tools/bundler, e.g. webpack, grunt, etc.
        - webpack will transpile, minify, bundle and compress front-end code
        - `npm install`
        - `npm run build`
  - refs:
    - <https://github.com/nvm-sh/nvm>
    - <https://stackoverflow.com/questions/74726224/opensslerrorstack-error03000086digital-envelope-routinesinitialization-e>
  - In Java:
    - bundle frontend app with webpack
    - manage dependencies with npm or Yarn
    - package everything into a WAR file
- As an alternative to publishing/pushing artifacts to Nexus or JFrog, companies are now using docker images as the only artifact. you still need to make an app out of JAVA with maven or gradle (jar/war files) and JS applications- use webpack or grunt to compress, minify.., but then what you do with that artifact afterwards is what makes the difference. The compiled, compressed files are then instead of being pushed to a repo, are used to make a docker image.
  - example node.js app Dockerfile:

    ```nodejs app Dockerfile
    FROM node:13-alpine

    RUN mkdir -p /usr/app

    COPY package*.json /usr/app/
    COPY app/* /usr/app

    WORKDIR /usr/app

    RUN npm install
    CMD ["node", "server.js"]
    ```

  - example java app Dockerfile

    ```java app Dockerfile
    FROM openjdk:8-jre-alpine

    EXPOSE 8080

    COPY ./build/libs/java-app-1.0-SNAPSHOT.jar /usr/app/
    WORKDIR /usr/app

    ENTRYPOINT ["java", "-jar" "java-app-1.0-SNAPSHOT.jar"]
    ```

  - execute tests on the build servers:
    - npm/yarn test
    - gradle/mvn test
  
  - __Apps from TWN-Devops Bootcamp github repos:__
  - <https://gitlab.com/twn-devops-bootcamp/latest/04-build-tools/java-app>
  - <https://gitlab.com/twn-devops-bootcamp/latest/04-build-tools/java-maven-app>
  - <https://github.com/techworld-with-nana/react-nodejs-example>
  - <https://gitlab.com/twn-devops-bootcamp/latest/04-build-tools/node-app.git>

- create the jar file:
  - `git clone https://gitlab.com/twn-devops-bootcamp/latest/05-cloud/java-react-example.git`
  - `cd java-react-example`
  - `gradle build`

- copying file from local to remote server:
  - ref:
    - <https://www.psychz.net/client/question/en/scp-from-local-machine-to-remote.html>
    - on the local machine:
      - `scp -i ~/Downloads/formac.pem build/libs/java-react-example.jar ubuntu@<remote IP>:/home/ubuntu`
  - on the remote server:
    - `sudo apt-get update`
    - `sudo apt install jdk-8-jre-headless`
    - `java -jar java-react-example.jar`
      - you can also run it in the background as: `java -jar java-react-example.jar &`
        - check for the process with `ps aux | grep java`
        - you can also kill the process running the `java -jar`
        - `kill <PID>`
      - check for servers with active connections: (install net tools)
        - `netstat -lpnt`
  - on the AWS console:
    - open port 7071 on the firewall
    - open the app on the browser at port 7071

  - create a new user:
    - `sudo adduser <username>`: add new user
    - `sudo usermod -aG sudo <username>`: add user to sudoers group
  - ssh into the remote server as new user
    - on your local:
      - `ssh-keygen -t rsa -b 4096 -C "likiphyllis@yahoo.com"`
      - `cat ~/.ssh/id_rsa.pub` copy the public key.
    - on the remote server:
      - `su - phyllis`
      - `mkdir ~/.ssh ; touch ~/.ssh/authorized_keys`
      - `vi ~/.ssh/authorized_keys`: past the public key and save
      - exit out of the server
    - now on the local machine you can login as the user:
      - `ssh phyllis@<remote server public ip address>`
    - now copy the jar file to /home/phyllis on the remote server:
      - `scp build/libs/java-react-example.jar phyllis@3<remote IP >:/home/phyllis`
