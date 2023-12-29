# specify a  base image that has npm
FROM node:14-alpine

WORKDIR /usr/app
# install some dependencies
COPY ./package.json ./

RUN npm install

#copy everything else
COPY ./ ./ 

# Default command
CMD [ "npm", "start" ]