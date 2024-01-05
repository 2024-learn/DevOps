## Building

__Build tools and package managers for different programming languages__
-
| Language  | Built tools            |
|-----------|------------------------|
| Java      | maven/ gradle/ ant     |
| JavaScript| npm/yarn/ webpack      |
| Python    | pip                    |
| C/ C++    | conan                  |
| C#        | NuGet                  |
| Golang    | dep                    |
| Ruby      | RubyGems               |    

__Useful Links:__
- Maven Repository: https://mvnrepository.com/
- NPM Repository: https://www.npmjs.com/package/repository

__examples of artifact repositories:__
  - Nexus, JFrog
  
- __Build tools in Java:__
  - __maven__
    - refs:
      - https://jenkov.com/tutorials/maven/maven-commands.html
      - https://www.geeksforgeeks.org/maven-lifecycle-and-basic-maven-commands/
    - uses xml
    - `mvn package`:
    - `mvn install`: installs dependencies, build the jar/war file and creates *target* file
    - dependencies are managed in *pom.xml*
    - Running the application:
      - `java -jar <>`
      - e.g. `java -jar target/java-maven-app-1.1.0-SNAPSHOT.jar`
  - __gradle__ 
    - refs:
      - https://gist.github.com/jiffle/499caa5f53ab8f90dc19a3040ee40f48
      - https://spring.io/guides/gs/gradle/
    - uses groovy
    - `gradle build`: installs the project dependencies, creates jar file and generated *build* file
    - dependencies are managed in *build.gradle*
    - Running the application:
    - `java -jar <path of the jar file>`
      - e.g. `java -jar build/libs/java-app-1.0-SNAPSHOT.jar`
      - 
  - both, maven and gradle, use the same dependency repository: https://mvnrepository.com/
  
  - How it works:
    - find a dependency with name and version
    - add it to the dependencies file (pom.xml)
    - the dependency gets downloaded locally (e.g local maven repo) so that it does not need to keep downloading it from the remote repo
    - locally the dependencies are in ~/.m2/repository folder
- __Build JS applications:__
  - No special artifact type. It has a zip or tar file
    - this inlcudes the application code but not the dependencies.
    - there are additional modules for npm and yarn that will add this functionality to include dependencies in the artifact
    - so whenever you wwant to run that artifact on a server, you first have to install the dependencies then unpack the zip/tar file and run the application like you would locally.
    - you need to copy the artifact and package.json file
  - you can use either npm or yarn for package managers (they are not build tools)
    - they build dependencies, but they are not used for transpiling JS code
  - package.json for dependencies
  - `npm install`: installs all the dependencies that are defined in the package.json file and also generates a package-lock.json file
    - package.json file is equivalvent to pom.xml in maven and build.gradle in gradle
  - npm repository for dependencies: https://npmjs.com
  - CLI:
    - `npm start`: start the application
    - `npm stop`: stop the application
    - `npm test`: run the tests
    - `npm pack`: creates an artifact
    - `npm publish`: publish the artifact to the artifact repository
    - ...
  - Javascript is much more flexible. It is not as structured and standardized as Java
  - __package front-end code:__
    - you can oackage frontend and backend code separately
    - or you can have a common packagge for both
    - frontend/react code needs to be transpiled
    - browsers do not support latest JS versions or other fancy code decorations, like JSX
    - code also needs to be compressed/minified to make sure the code runs faster in the browser
      - separate tools for that- buil tools/bundler, e.g. webpack, grunt, etc.
        - webpack will transpile, minify, bundle and compress front-end code
        - `npm install` 
        - `npm run build`
  - refs:
    - https://github.com/nvm-sh/nvm
    - https://stackoverflow.com/questions/74726224/opensslerrorstack-error03000086digital-envelope-routinesinitialization-e
  - In Java:
    - bundle frontend app with webpack
    - manage dependencies with npm or Yarn
    - package everything into a WAR file
- As an alternative to publishing/pushing artifacts to Nexus or JFrog, companies are now using docker images as the only artifact. you still need to make an app out of JAVA with maven or gradle (jar/war files) and JS applications- use webpack or grunt to compress, minify.., but then what you do with that artifact afterwards is what makes the difference. The compile, compressed files are then instead of being pushed to a repo, are used to make a docker image.
  - example node.js app Dockerfile:
    ```
    FROM node:13-alpine

    RUN mkdir -p /usr/app

    COPY package*.json /usr/app/
    COPY app/* /usr/app

    WORKDIR /usr/app

    RUN npm install
    CMD ["node", "server.js"]
    ```
  - example java app Dockerfile
    ```
    FROM openjdk:8-jre-alpine

    EXPOSE 8080

    COPY ./build/libs/java-app-1.0-SNAPSHOT.jar /usr/app/
    WORKDIR /usr/app

    ENTRYPOINT ["java", "-jar" "java-app-1.0-SNAPSHOT.jar"]
    ```
  - 