# Terraform - Infrastructure as Code

- Difference between Ansible and Terraform
| Ansible                                                           | Terraform                                                 |
|-------------------------------------------------------------------|-----------------------------------------------------------|
| mainly a configuration tool, deploy apps, install/update software | mainly infrastructure provisioning tool, can deploy apps  |
| more mature                                                       | relatively new- changing dynamically                      |
|                                                                   | more advanced in orchestration                            |

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
    - while AWS will create these by default if not specifies, it is best practise toy provision your own components instead of using the default
  - route table association
  - provision EC2 instance
    - move .pem key to your .ssh folder and set the permissions to 400
  - deploy nginx docker container
  - create a security group(firewall)

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
    - do not modularize just one resource. group several resources. eg. networking (vpc, subnet, firewall, route table..), ec2(instance, key pair)
    -
