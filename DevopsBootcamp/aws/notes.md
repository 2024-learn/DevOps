# AWS
- NACLs 
  - A network Access Control List allows or denies specific inbound or outbound traffic at a subnet level
  - they are stateless
  - https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html
- security groups 
  - controls traffic at an instance level
  - they are stateful
  - https://www.mygreatlearning.com/aws/tutorials/nacl-vs-security-group

- install docker:
  -`sudo yum install docker`
  - `docker --version`
- start docker daemon:
  -`sudo service docker start`
  - `ps aux | grep docker` or `sudo service docker status`
- change ownership of /var/run/docker.sock
  - `sudo chmod 666 /var/run/docker.sock`
  - alternatively add the ec2-user to the docker group:(recommended)
    - `sudo usermod -aG docker $USER` - logout and back in again for the change to take effect
- create docker image:
  - `git clone https://github.com/phyllisn-landmark/react-nodejs-example.git`
  - `docker login ...` this creates a .docker/config.json file that stores the login information so you don't have to keep logging in to dockerhub
  - `cd react-nodejs-example`
  - `docker build -t react-nodejs:1.0 .`
  - `docker tag react-nodejs:1.0 phyllisn/react-nodejs:1.0`
  - `docker push phyllisn/react-nodejs:1.0`
- install SSH agent plugin and create SSH credentials type on Jenkins server
  - plugin: SSH agent
  - create ssh credential type:
    - multibranch > credentials > SSH username with private key
    - generate pipeline syntax for the aws key credential
    - in Jenkinsfile `-o StrictHostKeyChecking=no`: suppress ssh pop-up. e.g.:
      ```
      def dockerCmd = 'docker run -p 3080:3080 -d phyllisn/react-nodejs:1.0'
      sshagent(['my-webserver-key']) {
        sh "ssh -o StrictHostKeyChecking=no ec2-user@35.182.64.68 ${dockerCmd}"
      }
      ```
    - open security group to allow jenkins server IP/32 to access the SSH port and the application port 3080
- Deploy to EC2 using docker-compose
  - install docker compose on ec2-server:
    - https://gist.github.com/npearce/6f3c7826c7499587f00957fee62f8ee9
    - `sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose`
    - Fix permissions after download:
    - `sudo chmod +x /usr/local/bin/docker-compose`
    - Verify success:
    - `docker-compose version` or `docker-compose --version`
- Install AWSCLI:
  - `brew install awscli` or https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
  - `aws configure`
    - configuration is stores in ~/.aws folder
  - `aws <command> <subcommand> [options and parameters]`
    - aws: the base call to the aws program
    - command: the aws service you wanto provision/make changes to
    - subcommand: specifies which operation to perform

- __Provisioning with AWS on the CLI:__
  - 
  - list security groups:
    - `aws ec2 describe-security-groups`
  - create a new security group:
    - you will need the vpc id to create the sg: `aws describe-vpcs`
    - `aws ec2 create-security-group --group-name --description "mySG --vpc-id vpc-XXXXXXXXXX`
    - `aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx`
    - allow inbound traffic on port 22:
      ```
      aws ec2 authorize-security-group-ingress \
      --group-id sg-xxxxxxx \
      --protocol tcp \
      --port 22 \
      --cidr <cidrblock>
      ```
  - create key pair:
    ```
    aws ec2 create-key-pair \
    --key-name MyKeyPair \
    --query 'KeyMaterial'\
    --output text > MyKeyPair.pem
    ```
  - list subnet ID:
    - `aws ec2 describe-subnets`
  - grab AMI from AWS UI
  - create AWS instance:
    ```
      aws ec2 run-instances
      --image-id ami-XXXXXXX
      --count 1
      --instance-type t2.micro
      --key-name MyKeyPair
      --security-group-ids sg-xxxxxx
      --subnet-id subnet-xxxxxx
    ```
  - change key permission:
    - `chmod 400 MyKeyPair.pem`

- create group:
  - `aws iam create-group --group-name sre`
- create user:
  - ` aws iam create-user --user-name phyllisCli`
- add user to the group:
  - `aws iam add-user-to-group --user-name phyllisCli --group-name sre`
    - `aws iam get-group --group-name sre`
- attach policy to group
  - this is the command so we need the policy-ARN 
    - `aws iam attach-user-policy --user-name MyUser --policy-arn {policy-arn}`(attach to user directly)
    - `aws iam attach-group-policy --group-name MyGroup --policy-arn {policy-arn}` (attach policy to group)
    - list AWS policies:
      ```
      aws iam list-policies --query 'Policies[?PolicyName==`AmazonEC2FullAccess`].Arn' --output text
      ```
        - `aws iam attach-group-policy --group-name MyGroup --policy-arn {policy-arn}`
      - validate policy attached to group or user
        - `aws iam list-attached-group-policies --group-name MyGroup - [aws iam list-attached-user-policies--user-name MyUser]`
      - Now that user needs access to the command line and UI, but we didn't give it any credentials. Solet's do that as well!
        - UI access
        - `aws iam create-login-profile --user-name MyUser --password My!User1Login8P@ssword--password-reset-required`
        - user will have to update password on UI or programmatically with the command:
          - `aws iam update-login-profile --user-name MyUser --password My!User1ADifferentP@ssword`
      - Create test policy
        - `aws iam create-policy --policy-name bla --policy-document file://bla.json`
      - cli access
        - `aws iam create-access-key --user-name MyUser`
        - you will see the access keys.
- ssh into the EC2 instance with this user:
  - `aws configure` with the new user creds:
    - `aws configure set aws_access_key_id default_access_key`
    - `aws configure set aws_secret_access_key default_secret_key`

    - `export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE`
    - `export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` 
    - `export AWS_DEFAULT_REGION=us-west-2`
