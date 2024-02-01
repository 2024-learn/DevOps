# EKS - Elastic Kubernetes Service

- Container orchestration tools: used for managing, scaling and deploying containers
  - Docker Swarm, Kubernetes, Mesos, Nomad, ECS, EKS, GKE, AKS ...
- Container Services on Kubernetes
  - ECS: Amazon's Elastic Container Service:
    - runs containerized app cluster on AWS.
    - ECS cluster contains all the services used to manage the containers
    - the EC2 instances where the containers are hosted are connected to and managed by ECS
      - services running on the EC2 instance:
        - container runtime
        - ECS agent: for control plane communication
    - you still have to manage the EC2 instances: create them, join them to the ECS cluster and when scheduling a new container, you have to make sure that you have enough resources, manage the server OS, updates, patches..., ensure you have the container runtime and ECS agent, etc.
    - Pro: Full access to your infrastructure
  - ECS with Fargate:
    - AWS Fargate: it is an alternative to EC2 instances. you create a fargate instance and connect it to the ECS cluster.
    - fargate is a serverless way to launch containers. It is mamanged by AWS
    - pros:
      - No need to provision and manage servers. You only need to manage your application
      - on demand
      - only pay for what you use because it only provisions the infrastructure resources needed to run your containers
      - Easily scales up and down without fixed resources defined beforehand
    - AWS fargate pricing is based on how ling the container runs and how much CPU and memory was requested for that container
  - EKS:
    - Alternative to EKS
    - used for managing a Kubernetes cluster on AWS infrastructure
    - EKS deploys and manages k8s control plane nodes with control plae services already installed on them
    - high availability- control plane nodes are replicated across availability zones.
      - i.e. if you are launching your EKS cluster in a zone that has 3 AZs, then you will get automatic replication of your control nodes on all three AZs
      - AWS also takes care of storing the ETCD data, replicating the ETCD store and backing it up properly.
    - You have to create the worker nodes (compute fleet) just like in ECS and connect them to EKS
    - pros:
      - kubernetes is open-source, unlike ECS with is AWS platform specific
      - easier to migrate to another platform
      - large community(Helm charts, etc)
    - EKS with EC2 instances: self managed-
      - you need to manage the infra for worker nodes
    - EKS with Nodegroup: semi managed-
      - you can group your worker nodes into nodegroups and the nodegroup(NG) can handle some of the heavy lifting
      - the NG will create, delete EC2 instances for you but you need to configure it
    - EKS with Fargate: fully managed-
      - fully managed worker nodes and control plane
    - setup EKS cluster:
      - provision an EKS cluster (control plane nodes)
      - create a nodegroup of EC2 instances (so you don't have to create EC2 instances individually)
      - connect the nodegroup(s) to the EKS cluster, or use fargate as an alternative
      - deploy your containerized apps using kubectl
  - ECR (Elastic Container Registry):
    - repo for docker images on AWS
    - alternative to DockerHub, Nexus, etc.
    - pros:
      - integrates well with other AWS services as it is part of the AWS ecosystem
  - Red Hat OpenShift Service on AWS:
    - fully managed Red Hat OpenShift service on AWS. Recently added

- Creating an EKS Cluster on UI
  - Create EKS IAM role:
    - assign the role to the EKS cluster(control plane) to allow AWS to create and manage components on our behalf
    - IAM > Roles > Create Role > Use Case (EKS - Cluster)
  - Create VPC for worker nodes
    - EKS cluster needs specific networking configuration(k8s specific and AWS specific networking rules) and the default VPC is not optimized for it.
      - the worker nodes needs specific firewall configurations for control plane <--> workernode communication
      - best practice: configure Public and Private subnets.
    - through IAM role, you give k8s permission to change VPC configurations - open ports on our behalf in our VPC
    - use a template from CloudFormation
      - <https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html>
  - Create EKS cluster (control plane nodes)
    - version: default
    - networking: choose the VPC created above
    - cluster endpoint access: public and private
  - Connect kubectl with EKS cluster
    - create a kubeconfig file
    - `aws configure list`
    - `aws eks update-kubeconfig --name eks-cluster-test`: will create a kubeconfig file locally
    - `cat ~/.kube/config`
    - `kubectl cluster-info`
  - Create EC2 IAM role for Node Group
    - kubelet on the worker nodes needs permission to make API calls to other AWS services
    - IAM > roles > create role > use case(ec2) > policies
      - AmazonEKSWorkerNodePolicy
      - AmazonEC2ContainerRegistryReadOnly
      - AmazonEKS_CNI_Policy
  - Create a nodeGroup and attach EKS cluster
    - nodegroup: logically groups EC2 instances together.
    - node IAM role; choose the role you created above
    - after the nodegroup is creates: `kubectl get nodes`
    - worker node processes are installed when creating the nodes with the node group
  - Configure autoscaling for the cluster
    - the autoscaling group is only there just to group the instances
    - has the configuration of minimum and maximum number of instances to scale down and up to
    - AWS/EKS doesn't automatically autoscale our resources. We have to configure a Kubernetes component (k8s Autoscaler) that is running inside the k8s cluster.
      - k8s component autoscaler and the AWS AutoScaling Group(ASG) will together be able to scale up/down automatically.
    - create a role for the node group. For autoscaling to work, we need to give the worker node instances permission to make AWS API calls.
      - create a custom policy:
        - IAM > policies > create policy > JSON

          ```node-group-autoscale-policy
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Action": [
                    "autoscaling:DescribeAutoScalingGroups",
                    "autoscaling:DescribeAutoScalingInstances",
                    "autoscaling:DescribeLaunchConfigurations",
                    "autoscaling:DescribeTags",
                    "autoscaling:SetDesiredCapacity",
                    "autoscaling:TerminateInstanceInAutoScalingGroup",
                    "ec2:DescribeLaunchtemplateVersions"
                    ],
                "Resource": "*",
                "Effect": "Allow"
              }
            ]
          }
          ```

      - attach policy to existing nodeGroup IAM role
        - roles > eks-node-group-role > addpermissions > attach policies > node-group-autoscale-policy
    - configure tags on the ASG
      - the k8s autoscaler we are going to deploy inside k8s will require to communicate and autodiscover auto scaling groups in the AWS account.
        - they are already configured automatically:
          - k8s.io/cluster-autoscaler/my-eks-cluster
          - k8s.io/cluster-autoscaler/enabled
    - deploy the cluster auto-scaler component which is a deployment component in our cluster
      - <https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml>
      - `kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml`
      - `kubectl get deploy -n kube-system cluster-autoscaler`
      - `kubectl edit deploy -n kube-system cluster-autoscaler`
        - add an annotation:
          - `cluster-autoscaler.kubernetes.io/safe-to-evict: "false"`
        - substitute the cluster name with your cluster name
          `- --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/my-eks-cluster`
        - add some more options:

          ```additional options
            - --balance-similar-node-groups
            - --skip-nodes-with-system-pods=false
          ```

        - change the image version to reflect the eks version running in the cluster
          - <https://github.com/kubernetes/autoscaler/tags>
            - `image: registry.k8s.io/autoscaling/cluster-autoscaler:v1.28.2`
        - `kubectl get pod -n kube-system`
        - `kubectl get pod <pod name> -n kube-system -o wide`
        - `kubectl logs -n kube-system <pod name>`
  - Deploy applications to the EKS cluster
    - deploy nginx application, load balancer.
    - `kubectl apply -f nginx.yaml`
    - `kubectl get pod`
    - `kubectl get svc`
    - you can now access the app on the browser using the loadbalancer endpoint
  - AWS has a requirement for loadbalancers:
    - have at least one ec2 instance in at least two different availabilty zones

- __Create Fargate Profile for EKS Cluster:__
  - fargate is a serverless way of deploying instances and creating pods in our cluster
  - difference between ec2 and fargate:
    - fargate: 1 pod per virtual machine
    - ec2: many pods running on the same instance
  - limitations when using fargate:
    - no support for stateful applications or DaemonSets yet
  - you can have fargate in addition to a nodegroup attached to the same EKS cluster
  - Create IAM Role for Fargate:
    - pods/kubelet on servers provisioned by fargate need permissions to make API calls to AWS on our behalf
    - AIM > roles > create role > use case: eks-fargate pod > policy: AmazonEKSFargatePodExecutionRolePolicy > name the role
  - Create Fargate Profile:
    - fargate profile creates a rule(pod selection rule). Specifies which pods should use fargate when they are launched
      - whenever we hand fargate a pod config or deployment yaml config, fargate based on the profile rules we defined can decide whether that pod should be scheduled through fargate.
      - fargate profile lets us define the criteria to decide how the new pod should be scheduled.
    - although we are not going to be provisioning our own ec2 instances with fargate, we provide a VPC because the pods that will be scheduled using Fargate will get an IP address from our Subnet range
      Fargate creates the pods only in the private subnet
      - eks cluster > compute > create fargate profile
        - configure pod selection: the pod selectors tell fargate which pods are meant to be scheduled by fargate
          - in the nginx.yaml add `namespace: dev`
          - we can also configure label selectors. eg. `profile: fargate` and add this key-value pair to the pod-selectors on the UI
    - Apply pod through fargate
      - `kubectl create ns dev`: the namespace needs to exist before the deployment referencing the ns
      - `kubectl apply -f nginx.yaml`
      - `kubectl get pods -n dev` or `kubectl get pods -n dev -w`: the -w flag = watch/wait
      - `kubectl get nodes -n dev`
  - Cluster cleanup
    - remove node group and fargate profile
    - delete eks cluster
    - delete roles
    - delete cloud-formation stack

- __EKS Cluster with `eksctl` CLI Tool:__
  - source code: <https://gitlab.com/twn-devops-bootcamp/latest/11-eks/eksctl>
    - <https://eksctl.io/usage/eks-managed-nodes/>
  - `eksctl` is a command line tool for working with EKS clusters, that automates many individual tasks
    - do not have to create roles.
    - execute just one command and the necessary components get created and configured in the background.
  - `eksctl create cluster`: the cluster gets configured with default parameters
    - with more CLI options you can customize the cluster
  - eksctl also manages and configures a cluster even after it is created; you can upgrade, add nodes, change nodegroup, add fargate profiles, etc.
  - when you create an EKS cluster using eksctl, it automatically installs AWS-IAM-authenticator
  - install `eksctl`
    - <https://github.com/eksctl-io/eksctl>
  - configure aws credentials with `aws configure`

    ```eksctl create cluster command
    eksctl create cluster \
    --name demo-cluster \
    --version 1.29 \
    --region ca-central-1 \
    --nodegroup-name demo-nodes \
    --node-type t2.micro \
    --nodes 2 \
    --nodes-min 1 \
    --nodes-max 3
    ```

  - you can also customize your cluster by using a config file: `eksctl create cluster -f cluster.yaml`. <https://eksctl.io>
    - example cluster.yaml:

    ```cluster.yaml
    kind: ClusterConfig
    apiVersion: eksctl.io/v1aplha5
    metadata:
      name: demo-cluster
      region: ca-central-1
    nodeGroups:
      - name: ng-1
        instanceType: m5.large
        desiredCapacity: 10
      - name: ng-1
        instanceType: t2.large
        desiredCapacity: 5
    ```

- __Deploy to EKS from Jenkins__
  - commands: <https://gitlab.com/twn-devops-bootcamp/latest/11-eks/deploy-to-eks-from-jenkins>
  - java-maven-project: <https://gitlab.com/twn-devops-bootcamp/latest/11-eks/java-maven-app>
  - Install kubectl cli tool inside jenkins container
    - in the Jenkins server, enter teh container as a root user to do the installation:
      - `docker exec -u 0 -it <jenkins container ID> bash`
      - `curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl; chmod +x ./kubectl; mv ./kubectl /usr/local/bin/kubectl`
  - Install aws-iam-authenticator tool inside jenkins container
    - <https://github.com/kubernetes-sigs/aws-iam-authenticator/releases>
    - `curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.14/aws-iam-authenticator_0.6.14_linux_amd64`
    - `chmod +x ./aws-iam-authenticator`
    - `mv ./aws-iam-authenticator /usr/local/bin`
    - `aws-iam-authenticator help`
  - Create a kubeconfig file for jenkins, to connect to EKS cluster
    - create the kubeconfig file manually, outside the container then copy it to the container
      - cat ~/.kube/config
        - copy the certificate-authority data and server and also adjust the arguments to reflect your cluster
      - copy the config file into the container from the Jenkins Server
        - in the container:
          - `mkdir .kube`
          - `exit`
        - on the jenkins server:
          - `docker cp config <containerID>:/var/jenkins_home/.kube/`
          - `docker exec -it 57472e4eedf2 bash`
          - `cd ~`
          - `cat ./kube/config`
  - Add AWS credentials on Jenkins for AWS account authentication
    - best practice: create AWS IAM user for Jenkins with limited permissions
    - new branch 'deploy-on-k8s'
    - on the multibranch pipeline, add pipeline credentials
      - credentials > kind: secret text
      - `cat .aws/credentials`
      - copy the access key and secret access key(separate credentials)
      - adjust the Jenkinsfile. add the new credentials in the Jenkins UI as enviroment vars <https://gitlab.com/likiphyllis/aws-multibranch/-/blob/deploy-on-k8s/Jenkinsfile?ref_type=heads>
      - build the pipeline.
  - Adjust Jenkinsfile to configure EKS cluster deployment
  - credentials best practice:
    - create jekins servie account in kubernetes and limit permissions. eg. deploy application to specific namespace, create deployment and service resources, etc.
    - create credentials for Jenkins user inside the cluster with a user token

- __Complete CI/CD Pipeline with EKS and DockerHub:__
  - code: java-maven-app branch <https://gitlab.com/likiphyllis/aws-multibranch.git>
  - envsubst: environment substitute command
    - used to substitute any variables defined inside a file
    - envsubst is a tool we need to install inside Jenkins container
    - how it works: we pass a file to envsubst command and it will take that file, look for the syntax $ and name of the variable and it will try to match that name of the variable to any env. vars defined in that context and sustitute that value
    - it creates a temporary file with the values set, and we pipe that temporary file and pass it as a parameter
  - install "gettext-base" tool on Jenkins container:
    - `docker exec -u 0 -it <container ID> bash`
    - `apt-get install gettext-base`
  - The dockerhub credentials must also be available in the k8s cluster
    - we do that by creating a special secret of docker registry type with the credentials(username and password).
      - We only need to create the secret once, so we do not need to put this in the pipeline. We can create that from our local machine.
        - docker-registry: secret type
        - my-registry-key: name of the secret
        - docker-server: dockerhub name (if nexus: URL of the nexus repo, if ECR, you can copy the URL frowm AWS ECR)
        - docker-username: username that you use to login to your repository

        ```docker-registry-secret
        kubectl create secret docker-registry my-registry-key \
        --docker-server=docker.io \
        --docker-username=phyllisn \
        --docker-password=XXXX
        ```

      - `kubectl get secret`

      ```secret-output
      kget secret
      NAME              TYPE                             DATA   AGE
      my-registry-key   kubernetes.io/dockerconfigjson   1      12s
      ```

      - `kubectl delete deploy --all`

- __Complete CI/CD Pipeline with EKS and ECR:__
  - code: eks-ecr branch <https://gitlab.com/likiphyllis/aws-multibranch.git>
  - create ECR repository
    - ECR allows unlimited number of repos, so you can host a repo per app
    - you can create a repo for each microservice and have multiple versions in each repo
  - create credentials for ECR repo in Jenkins
    - `aws ecr get-login-password --region ca-central-1` gives you the password that is then piped into the rest of the push command
    - create the credentials on Jenkins UI (global)
      - username AWS
      - ID: ecr-credentials
      - password: value from the output of: `aws ecr get-login-password --region ca-central-1`
    - create secret for AWS ECR
      - `kubectl create secret docker-registry aws-registry-key --docker-server=137236605350.dkr.ecr.ca-central-1.amazonaws.com --docker-username=AWS --docker-password=<value of password above>`
      - `kubectl get secret`

        ```kget secret
        NAME               TYPE                             DATA   AGE
        aws-registry-key   kubernetes.io/dockerconfigjson   1      29s
        my-registry-key    kubernetes.io/dockerconfigjson   1      69m
        ```

  - adjust building and tagging
    - `imagePullSecrets name: aws-registry-key`
  - update Jenkinsfile
    - change credentials to ecr-credentials that was created in the Jenkins UI.
    - change the repo name
  - execute jenkins pipeline

  - cleanup
    - `eksctl delete cluster --name=demo-cluster --wait`

- __Best Practices:__
  - Security- AWS KMS: <https://docs.aws.amazon.com/eks/latest/userguide/enable-kms.html>
  - EKS best practices: <https://aws.github.io/aws-eks-best-practices/>
