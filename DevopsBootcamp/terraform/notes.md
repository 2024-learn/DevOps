# Terraform - Infrastructure as Code

- Difference between Ansible and Terraform
  - Ansible
    - mainly a configuration tool, deploy apps, install/update software
    - more mature
  - Terraform
    - mainly a configuration tool, deploy apps, install/update software
    - mainly infrastructure provisioning tool, can deploy apps
    - relatively new- changing dynamically
    - more advanced in orchestration

- __Terraform architecture:__
  - terraform has two main components that make up its architecture.
    - core:
      - the core uses two input sources:
        - terraform configuration that the user writes
        - terraform state
      - the core takes the input and figures out the plan of what needs to be done by comparing the desired state and current state
    - providers:
      - the cloud providers from whom the infrastructure is provisioned like AWS, Azure, GCP [IaaS], Kubernetes [PaaS], Fastly [SaaS]
      - through the providers, terraform user gets access to its resources

- __terraform commands:__
  - `init`: initializes a tf working directory and installs providers defined in the terraform configuration
  - `refresh`: query infrastructure provider to get current state
  - `plan`: create an execution plan. determines what actions are necessary to achieve the desired state
    - `+`create
    - `-`destroy
    - `~` modify/update in place
  - `apply`: executes the plan. requires an input (yes) to apply
    - if you want to apply without having to do any confirmation: `terraform apply -auto-approve`
  - `destroy`: destroy the resources/infrastructure in the order of dependencies. requires an input (yes) to apply
    - `terrraform destroy -target aws_subnet.dev_subnet_2`: destroys specific resources(not recommended becasue it changes the resources without changing the configuration)
    - recommended: Delete the resource(s) from the configuration file and use `terraform apply`, that way the configuration file can match the desired state.

- __install terraform:__
  - `brew tap hashicorp/tap`
  - `brew install hashicorp/tap/terraform`

- providers need to be installed using `terraform init`
  - while this block is optional for official providers, non-offial providers like OCI and Alibaba require it

  ```providers
  terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "5.34.0"
      }
    }
  }
  ```

- availability zones: to find out which AZs are available for your region you can run: `aws ec2 describe-availability-zones --region region-name`
- resource sources: allow you to create new infra resources
  - name must be unique for each resource type
- data sources: allow data to be fetched for use in tf configuration
  - result of the query is exported under the specified name
  - arguments: filter for query
- terraform state: a JSON file where tf stores the current state of your real world resources in your managed infrastructure
- backup statefile: stoes teh previous tf state
- terraform state subcommands:
  - `list`: list resourcees in the state
  - `mv`: move an item in the state
  - `pull`: Pull current state and output to stdout
  - `push`: Update remote state from a local state file
  - `replace-provider`: Replace provider in the state
  - `rm`: Remove instances from the state
  - `show`: Show a resource in the state
- output values are like function return values
- input variables are like function arguments.
  - they enable reusability. variabes can be used to replicate infrastructure in different envs.
  - three ways of providing a value to an input variable:
    - tf apply and wait for the cli to prmpt you for the value
    - `terraform apply -var "<variable name>=<value>"`
      - `terraform apply -var "subnet_cidr=10.10.0.0/24"`
    - (best practice): a variables file
      - set the values in a file called terraform.tfvars. You can customize the name of this fie but you need to provide it at apply. `terraform apply -var-file terraform-dev.tfvars`
    - a default value makes the variable optional. tf will look for values in the tfvars file or in the module and if it cannot find the value there, then it will use the default value.
    - type specifies what type of values are accepted
    - *simple variable*:

    ```simple-variable
    resource "aws_vpc" "dev_vpc" {
      cidr_block = var.vpc_cidr
    }
    resource "aws_subnet" "dev_subnet" {
      vpc_id = aws_vpc.dev_vpc.id
      cidr_block = var.subnet_cidr
      availability_zone = "ca-central-1a"
    }

    --- variables.tf

    variable "vpc_cidr" {
      default = "10.0.0.0/8"
    }
    variable "subnet_cidr" {}
     
    --- terraform.tfvars
    vpc_cidr = "10.0.0.0/16"
    subnet_cidr = "10.10.0.0/24"
    ```

    - *list of string:*

    ```list of string
    variables.tf
    variable "cidr_blocks" {
      type = list(string)
    }

    --- terraform.tfvars
    cidr_blocks = ["10.0.0.0/16", "10.0.60.0/24"]

    --- main.tf
    resource "aws_vpc" "dev_vpc" {
      cidr_block = var.cidr_blocks[0]
    }
    resource "aws_subnet" "dev_subnet" {
      vpc_id = aws_vpc.dev_vpc.id
      cidr_block = var.cidr_blocks[1]
      availability_zone = "ca-central-1a"
    }
    ```

    - *list of objects:*

    ```list of objects
    --- variables.tf
    variable "cidr_blocks" {
      type = list(object({
        cidr_block = string
        name = string
      }))
    }

    --- teraform.tfvars
    cidr_blocks = [
      {cidr_block = "10.0.0.0/16", name = "vpc-cidr"},
      {cidr_block = "10.0.60.0/24", name = "subnet_cidr"}
    ]

    --- main.tf
        resource "aws_vpc" "dev_vpc" {
      cidr_block = var.cidr_blocks[0].cidr_block
      tags = {
        name: var.cidr_blocks[0].name
      }
    }
    resource "aws_subnet" "dev_subnet" {
      vpc_id = aws_vpc.dev_vpc.id
      cidr_block = var.cidr_blocks[1].cidr_block
      availability_zone = "ca-central-1a"
      tags = {
        name: var.cidr_blocks[1].name
      }
    }
    ```

- env. vars in tf
  - you can set global variables with `TF_VAR_<name of variable>="value"`
    - e.g. `TF_VAR_availability_zone="eu-central1-a"`

- provision EC2
  - create custom vpc
  - create custom subnet
  - create route table and internet gateway
    - while AWS will create these by default if not specifies, it is best practice to provision your own components instead of using the default
  - route table association
  - provision EC2 instance
    - move .pem key to your .ssh folder and set the permissions to 400
  - deploy nginx docker container
  - create a security group(firewall)
  - user_data: the script that runs once as your instace is provisioning
  - eg. *user-data*

    ```user-data.sh
      user_data = <<-EOF
                  #!/bin/bash
                  sudo yum update -y && sudo yum install -y docker
                  sudo systemctl start docker
                  sudo usermod -aG docker ec2-usersudo
                  chmod 666 /var/run/docker.sock
                  docker run -d -p 8080:80 nginx
                EOF
    ```

- provisioners
  - "remote-exec" provisioner:
    - invokes script on a remote resource after it is created
    - inline = list of commands
    - eg. *remote-exec provisioner*

    ```remote-exec
    connection{
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key_location)
    }
    provisioner "remote-exec" {
      inline = [
        "export ENV=dev",
        "mkdir newdir"
      ]
    }
    ```

  - "file" provisioner:
    - copies files of directories from local to newly created resource
    - source: source of file or folder
    - destination: absolute path
    - e.g. *file provisioner(inline)*

    ```file provisioner(inline)
    connection{
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key_location)
    }
    provisioner "file" {
      source = "user-data.sh"
      destination = "/home/ec2-user/user-data.sh"
    }
    provisioner "remote-exec" {
      inline = ["/home/ec2-user/user-data.sh"]
    }
    ```

    - e.g. *file provisioner(script)*

    ```file provisioner(script)
    connection{
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key_location)
    }
    provisioner "file" {
      source = "user-data.sh"
      destination = "/home/ec2-user/user-data.sh"
    }
    provisioner "remote-exec" {
    script = "user-data.sh"
    }
    ```

  - you can have the connection block inside the provisioner if you are trying to copy that file to other servers as well
  - "local-exec" provisioner:
    - will be executed locally, not on the create resource
    - invokes a local executable after a resource is created
    - e.g. *local-exec provisioner*

    ```local-exec
    connection{
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key_location)
    }
    provisioner "file" {
      source = "user-data.sh"
      destination = "/home/ec2-user/user-data.sh"
    }
    provisioner "remote-exec" {
      script = "user-data.sh"
    }
    provisioner "local-exec" {
      command = "echo ${self.public_ip} > output.txt"
    }
    ```

  - Terraform does not recommend the use of provisioners: <https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#provisioners-are-a-last-resort>
    - use user_data if available
    - breaks idempotency concept.
  - alternative to local-exec
    - use "local" provider

  - modules: they are like function definitions.
    - input vars: like function arguments
    - output values: like function return values
      - to expose/export resource attributes to parent module
    - do not modularize just one resource. group several resources. eg. networking (vpc, subnet, firewall, route table..), ec2(instance, key pair)

    - project structure
      - root module
      - /modules = child modules
        - child module: a module that is called by another configuration

    - values are defined in .tfvars file and set as valuables in variables.tf in the root module, the values are passed to the child module as arguments via variables.tf in the child module
  
  - __EKS__
    - single_nat_gateway : all private subnets will route their internet traffic through this single NAT gateway
    - tags: for human consumption to provide us with more information
      - they are also used as a label for referencing components from other components(programmatically)
      - e.g. cloud controller manager - the private and public_subnet_tags help the cloud controller manager identify which VPC and subnets it should connect to.
        - these tags are for consumption by the k8s cloud controller manager and AWS load balancer controller that is responsible for creating load balancers for k8s loadbalancer types
    - cluster_version = kubernetes version
    - subnet_ids: list of subnets where the worker nodes will be started.
      - private: for the workloads
      - public: for external resources like loadbalancers
    - update kubeconfig:
      - pre-requisites:
        - aws cli installed
        - kubectl installed
        - aws-iam-authenticator installed
      - `aws eks update-kubeconfig --name myapp-eks-cluster --region us-east-2`
      - we still need to enable public access to the cluster.
        - `cluster_endpoint_public_access =  true` makes the k8s cluster it the API server process on the k8s cluster publicly accessible from external clients like kubectl from our local computer
        - run `aws eks update-kubeconfig --name myapp-eks-cluster --region us-east-2` again
        - and now you will be able to run kubectl commands
  
  - __CI/CD pipeline with Terraform:__
    - code: <https://gitlab.com/likiphyllis/java-maven-app.git> (jenkinsfile-sshagent branch)
    - stage("provision server")
      - steps to do:
        - create ssh key pair on AWS:
          - in the multip-pipeline branch, create project-scoped credentials(ssh username with private key)
          - username: ec2-user
        - install tf inside jenkins container
          - enter the container as a root user: `docker exec -u 0 -it <containerid> bash`
          - check OS system to find the right installation instructions:
            - `cat /etc/os-release`
            - <https://developer.hashicorp.com/terraform/install>
            - `apt-get install wget`
            - `apt-get update && apt-get install -y lsb-release && apt-get clean all`
        - tf configuration to provision server
          - create terraform configuration files in a terraform folder in java-maven-app code
        - adjust Jenkinsfile
          - configure stages
            - `dir`: helps to provide the path of the folder with the terraform configuration
            -
    - installation documentation for docker-compose standalone: <https://docs.docker.com/compose/install/standalone/>
  
- terraform remote state file
  - terraform block provides mtadata and information about terraform itself
  - backend: the remote backend for terraform.
    - determines how state is loaded/stored
    - default: local storage
    - key: the path inside the s3 bucket. it can have a folder/hierarchy structure
  - to access the list of resources uploaded to the s3 backend bucket:
    - (on jenkinsfile-sshagent branch):
      - `cd terraform`
      - `terraform init`
      - `terraform state list`
  - the bucket has to be created before using it as a backend
  - delete the resources before deleting the backend

- __Best Practices:__
  - Only manipulate the state with tf apply and tf state commands.
    - do not make changes to the state file directly
  - Always set up a shared remote storage if working in a team
  - Use state locking until an update is fully completed, to prevent concurrent edits to your statefile, which break idempotency
    - in s3,DynamoDB service is automatically used for state locking
    - note: not all backends support locking
    - if supported, terraform will lock your statefile automatically
  - backup the statefile
    - enable versioning and the you can use a previous version to reverse to
  - use one state per environment with a backend and locking configured
  - host tf scripts in a git repo for effective team collaboration and version control of IaC code
  - Treat tf code just like your app code
    - same process for reviewing and testing changes with pull/merge requestes to integrate code changes
  - execute terraform in an automated build
    - apply infra changes only through an automated build
