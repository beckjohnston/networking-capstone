# networking-capstone
## Network Infrastructure
<img width="1042" height="725" alt="Screenshot 2026-08-07 143217" src="https://github.com/user-attachments/assets/23d8c65a-3e75-40ec-810b-17548736b21a" />



## To Do

 - Terraform project
 - Ansible files
 - GitHub Actions/CI CD
 - Presentation work
 - Create a diagram for the README/presentation

### Terraform Project
Create a terraform project

### Ansible Project
 - Create and connect various nodes.
   - Detail where the inventory file can be changed in case the node's IP changes
   - Make it possible to create the inventory file using the Terraform output via GitHub Actions
 - Create scripts for verifying and connecting to the created instances
    - Try to make example scripts for httpd, different software downloads, etc.
    - Make the program OS agnostic. Start with compatibility with Amazon Linux.
 - Try to make the project as easy to modify as possible. Variable files, etc.
    - Host names for nodes should be easily marked and detailed instructions for modification should be available in the README.md.
 - Attach monitoring software such as Grafana or Prometheus.
    - Find a way to install the software onto the nodes using Docker.
    - Note the exact URL necessary for accessing the software in the README.md file.

### GitHub Action - CI/CD
 - Configure the workflow to be triggered by a pull request.
 - Perform a dry run in Terraform and Ansible prior to applying changes.

### Presentation Work
 - Finalize the README.md file with detailed descriptions for the use of all features.
   - Highlight how to modify the Terraform and Ansible files based on varying needs or changes
 - Create a slide deck for the in-person presentation.
 - Either get the project working on a laptop for use in the presentation or create a video of how the project functions.
   - A video might need to be edited as Terraform can be very slow when being run


##Terraform

#Overview

The Terraform portion of the Networking Capstone provisions the AWSinfrastructure required for the project. The environment is divided intothree VPCs for application workloads, observability infrastructure, andnetwork routing.

Terraform manages:

Three AWS VPCs

Public and private subnets

EC2 instances

Cisco Catalyst 8000V router infrastructure

Internet Gateways

NAT Gateway

Route tables

Security groups

AWS Transit Gateway

Transit Gateway VPC attachments

AWS Customer Gateway

AWS Site-to-Site VPN

BGP tunnel addressing

Elastic IP addresses

SSH key infrastructure

S3 remote state

DynamoDB state locking

AWS IAM and GitHub OIDC infrastructure

Application VPC

The Application VPC uses:

10.0.0.0/16

It contains three subnets:

Subnet      CIDR            Purpose

Public      10.0.1.0/24   Bastion host and NAT GatewayPrivate 1   10.0.2.0/24   Private application EC2 instancePrivate 2   10.0.3.0/24   Private application EC2 instance

Bastion Instance

Terraform provisions an Amazon Linux EC2 bastion instance in the publicapplication subnet.

The bastion receives a public IP address and uses the bastion securitygroup.

Private Application Instances

Terraform provisions two Amazon Linux EC2 instances:

private-app-1

private-app-2

Each instance is placed in a separate private subnet.

The instances use the private_app role tag and the applicationsecurity group.

NAT Gateway

Terraform provisions an Elastic IP and NAT Gateway in the ApplicationVPC public subnet.

The private application route table sends its default route through theNAT Gateway:

0.0.0.0/0 -> NAT Gateway

Both private application subnets are associated with this route table.

This allows the private EC2 instances to initiate outbound Internetconnections without requiring public IP addresses.

Observability VPC

The Observability VPC uses:

10.1.0.0/16

It contains:

Subnet    CIDR            Purpose

Public    10.1.1.0/24   Grafana EC2 instancePrivate   10.1.2.0/24   Prometheus EC2 instance

Grafana Instance

Terraform provisions an Amazon Linux EC2 instance for Grafana in thepublic observability subnet.

The instance receives a public IP address and uses the Grafana securitygroup.

Prometheus Instance

Terraform provisions an Amazon Linux EC2 instance for Prometheus in theprivate observability subnet.

The instance uses the Prometheus security group and does not require adirectly assigned public IP address.

Network VPC

The Network VPC uses:

10.2.0.0/16

The network public subnet uses:

10.2.1.0/24

This VPC contains the Cisco routing infrastructure.

Cisco Catalyst 8000V EC2 Instance

Terraform provisions the Cisco Catalyst 8000V as an EC2 instance usingthe Cisco Marketplace AMI:

ami-0be014c32727a2444

The instance type is:

c5.large

The router is tagged:

Name = catalyst-router

Role = router

EC2 source/destination checking is disabled so the instance can forwardnetwork traffic.

Router Network Interfaces

The Catalyst instance has its primary EC2 network interface and anadditional Terraform-managed network interface.

The secondary interface is attached using device index 1.

Source/destination checking is also disabled on the secondary interface.

Router Elastic IP

Terraform provisions an Elastic IP for the Catalyst router.

The Elastic IP provides a stable public address for the router and isassociated with the router EC2 instance.

The same public address is used by the AWS Customer Gateway resource toidentify the Cisco endpoint.

Internet Gateways

Terraform provisions an Internet Gateway for each VPC:

Application Internet Gateway

Observability Internet Gateway

Network Internet Gateway

The public route tables use:

0.0.0.0/0 -> Internet Gateway

This provides Internet connectivity to resources located in the publicsubnets.

Route Tables

Terraform manages separate route tables for the public and privateportions of the environment.

Application Public Route Table

The Application VPC public route table sends Internet-bound trafficthrough the Application Internet Gateway.

Application Private Route Table

The Application VPC private route table sends Internet-bound trafficthrough the NAT Gateway.

Both private application subnets are associated with this route table.

Observability Public Route Table

The Observability VPC public route table sends Internet-bound trafficthrough the Observability Internet Gateway.

Network Public Route Table

The Network VPC public route table sends Internet-bound traffic throughthe Network Internet Gateway.

AWS Transit Gateway

Terraform provisions an AWS Transit Gateway as the centralized AWSrouting component.

The Transit Gateway uses:

Amazon-side ASN: 64512

Default Transit Gateway route-table association and propagation aredisabled so the project explicitly defines these relationships.

Terraform also creates a dedicated Transit Gateway route table.

Transit Gateway VPC Attachments

Terraform attaches all three VPCs to the Transit Gateway.

Application Attachment

The Application VPC attachment uses:

10.0.2.0/24

10.0.3.0/24

These are the two private application subnets.

Observability Attachment

The Observability VPC attachment uses:

10.1.2.0/24

Network Attachment

The Network VPC attachment uses:

10.2.1.0/24

Terraform associates each attachment with the dedicated Transit Gatewayroute table.

Terraform also enables route propagation for the Application,Observability, and Network attachments.

AWS Customer Gateway

Terraform creates an AWS Customer Gateway representing the CiscoCatalyst router.

The Customer Gateway uses:

Cisco BGP ASN: 64525

Its IP address is the Elastic IP assigned to the Catalyst router.

The Customer Gateway acts as the AWS-side representation of the externalCisco endpoint used by the Site-to-Site VPN.

AWS Site-to-Site VPN

Terraform provisions an AWS Site-to-Site VPN connection between:

The Cisco Customer Gateway

The AWS Transit Gateway

The VPN uses dynamic routing rather than static routes.

The VPN attachment is also configured for propagation into theTerraform-managed Transit Gateway route table.

BGP Tunnel Infrastructure

Terraform defines the inside CIDR ranges for both Site-to-Site VPNtunnels.

Tunnel 1

Tunnel CIDR:

169.254.185.68/30

Addresses derived from the Terraform VPN resource are:

AWS side: 169.254.185.69

Cisco side: 169.254.185.70

Tunnel 2

Tunnel CIDR:

169.254.232.88/30

Addresses derived from the Terraform VPN resource are:

AWS side: 169.254.232.89

Cisco side: 169.254.232.90

The Terraform infrastructure therefore provides the AWS networkingresources and addressing required for the BGP relationship between theCatalyst router and Transit Gateway.

The autonomous system numbers are:

Cisco Catalyst: 64525

AWS Transit Gateway: 64512

Security Groups

Terraform creates separate security groups for each major infrastructurerole.

Bastion Security Group

Provides SSH access to the bastion host and allows outbound traffic.

Application Security Group

Provides SSH access from the bastion and permits TCP port 9100 trafficrequired by the application monitoring architecture.

Grafana Security Group

Provides TCP port 3000 access for the Grafana interface and controlledSSH access.

Prometheus Security Group

Provides the network permissions required for Prometheus and monitoringtraffic.

Router Security Group

Provides:

TCP 22 for SSH

TCP 179 for BGP

Outbound traffic is permitted from the router.

SSH Key Infrastructure

Terraform defines a 4096-bit RSA private key using the TLS provider.

The generated public key is registered as an AWS EC2 key pair.

The generated private key is stored in AWS Systems Manager ParameterStore as a SecureString.

The parameter naming convention is:

/networking-capstone/dev/ssh-key

This keeps the Terraform-managed private key in AWS rather than storingit directly in the repository.

Terraform Remote State

Terraform uses an S3 backend.

The state bucket is:

beck-networking-capstone-tfstate-2026

The Terraform state object is:

networking-capstone/terraform.tfstate

The S3 state infrastructure includes:

Versioning

Public-access blocking

Server-side encryption

Deletion protection

Terraform State Locking

Terraform uses the DynamoDB table:

networking-capstone-tf-locks

The table uses LockID as its partition key and provides state lockingfor the shared Terraform backend.

The S3 bucket and DynamoDB table are backend infrastructure and aremaintained separately from the disposable project resources.

AWS IAM and GitHub OIDC

Terraform provisions an AWS IAM OpenID Connect provider for GitHub.

The OIDC provider trusts:

token.actions.githubusercontent.com

Terraform also provisions the IAM role:

gha-networking-capstone-deploy

The role trust policy restricts access according to the configuredGitHub repository.

The role has AWS PowerUserAccess attached.

Terraform Outputs

Terraform exposes infrastructure information needed by other parts ofthe project, including:

VPC IDs

Subnet IDs

Security group IDs

Bastion public IP

Application private IPs

Grafana public IP

Prometheus private IP

Router public IP

Router management IP

Router inside-interface IP

Router VPN Elastic IP

NAT Gateway public IP

NAT Gateway private IP

NAT Gateway ID

Private route table ID

Transit Gateway ID

Transit Gateway ASN

Customer Gateway ID

VPN connection ID

Tunnel 1 AWS-side IP

Tunnel 1 Cisco-side IP

Tunnel 2 AWS-side IP

Tunnel 2 Cisco-side IP

Terraform Infrastructure Summary

Terraform-Managed Component         Purpose

Application VPC                     Hosts application infrastructure

Application public subnet           Hosts bastion and NAT Gateway

Application private subnets         Host private application EC2instances

Bastion EC2                         Public administrative entry point

Application EC2 instances           Private application workloads

NAT Gateway                         Outbound Internet connectivity forprivate application subnets

Observability VPC                   Hosts monitoring infrastructure

Grafana EC2                         Public observability instance

Prometheus EC2                      Private observability instance

Network VPC                         Hosts routing infrastructure

Catalyst 8000V EC2                  Cisco software router

Router secondary ENI                Additional router network interface

Router Elastic IP                   Stable public router/VPN endpoint

Internet Gateways                   Public Internet connectivity

Route tables                        Control subnet traffic paths

Transit Gateway                     Central AWS routing component

TGW VPC attachments                 Attach all three VPCs to theTransit Gateway

TGW route table                     Controls Transit Gateway routing

Customer Gateway                    Represents the Cisco router to AWS

Site-to-Site VPN                    Connects the Cisco router to theTransit Gateway

VPN tunnel CIDRs                    Provide point-to-point BGPaddressing

Security groups                     Control EC2 network access

EC2 key pair                        Provides SSH public-keyauthentication

SSM SecureString                    Stores the Terraform-generatedprivate key

S3 bucket                           Stores remote Terraform state

DynamoDB table                      Provides Terraform state locking

IAM OIDC provider                   Establishes GitHub identityfederation with AWS

### Ansible

#### Inventory

 - The inventory file automatically changes based on the instances configured in the targeted AWS account
 - Need to query AWS for the targeted hosts based off of the tags provided at initialization of the instances.
 - Also possible to query through GitHub Action, however that has limited use.

#### Playbooks

##### install_observability

 - Installs various packages on the targeted nodes. Bastion, Prometheus, Grafana in that order
```
   ansible-playbook \
      -i ansible/inventory/aws_ec2.yml \
      -e "ansible_ssh_private_key_file=${{ secrets.EC2_INSTANCES_PRIVATE_KEY }}" \
      -e "grafana_admin_password=<your-password>" \
      ansible/playbooks/install_observability.yml
```

 - Command should be using the inventory file that queries the AWS account. 
 - The ssh private key will need to be retrieved from the output of the terraform file
 - The grafana password will need to be retrieved from the GitHub Secrets in order to be secure

##### verify_connectivity

 - Tests the connectivity between the public Bastion instance and the private application instances.
 ```
   ansible-playbook -i ansible/inventory/aws_ec2.yml ansible/playbooks/verify_connectivity.yml
```
 - Runs based on the inventory file that queries the AWS account associated with terraform

##### router_config
 - Imports and runs the router_config.j2 template onto the Cisco Catalyst 8000V router.

```
   ansible-playbook \
      -i ansible/inventory/aws_ec2.yml \
      -e "ansible_ssh_private_key_file=${{ secrets.EC2_INSTANCES_PRIVATE_KEY }}" \
      ansible/playbooks/router_config.yml
```

 - Requires the following parameters from the terraform outputs to be able to run.
      - router_management_ip:             Private IP of the router
      - vpn_connection_id:                AWS id number for the VPN that was created
      - customer_gateway_id:              AWS id number assigned to the Customer Gateway that was created
      - router_vpn_public_ip:             Public IP that is used for the CGW and the end-point for the tunnel
      - vpn_tunnel1_router_inside_ip:     The Ip for the router side of the BGP tunnel
      - vpn_tunnel1_aws_inside_ip:        The IP for the AWS side of the BGP tunnel

 - See **LINK TO BGP DOCUMENTATION** for details on the implementation of router_config.j2

#### Roles

##### Grafana

 - Creates an instance of Grafana on the targeted node. Must be utilized with Prometheus.
 - Grafana password must be stored in GitHub secrets and called manually from GitHub Actions.
      ansible-playbook -i inventory_file playbook.yml -e "grafana_admin_password=password"

##### Prometheus

 - Creates an instance of Prometheus on the targeted node. 
 - Must be configured with Bastion to be able to scrape from VPC 1

##### Bastion

 - Creates a link between a preapproved node and the targeted node regardless of whether they are on the same VPC.
 - Needs configuration for keys generated by Terraform, session recording is an option if needed, but needs configured


### GitHub Actions

#### ansible.yml
 - Triggered by a pull request on the main branch for automated deployment.
 - Manually triggered on the test branch for debugging.
 - Performs a dry run and posts output as a comment in the pull request.
 - Runs the ansible playbooks.

#### terraform.yml
- Triggered by a pull request on the main branch for automated deployment.
- Manually triggered on the test branch for debugging.
- Takes input of plan, apply, or destroy to determine which terraform command to run.
- Posts terraform plan output as a comment in the pull request before applying changes.
- Runs terraform init and validate before planning or applying.
- Allows for a terraform destroy option for the clean deletion of resources.



Transit ASN: 64512

  
 pptx link : https://onedrive.live.com/:p:/g/personal/2dc866dcd3e1fe1d/IQCzgyaUMomDQZJtofj93lLDATa5H89nk-nIbJanmtNGYMY?rtime=_v-9K4Dt3kg&redeem=aHR0cHM6Ly8xZHJ2Lm1zL3AvYy8yZGM4NjZkY2QzZTFmZTFkL0lRQ3pneWFVTW9tRFFaSnRvZmo5M2xMREFUYTVIODluay1uSWJKYW5tdE5HWU1ZP2U9Q1ZyZFcz

diagram link: https://lucid.app/lucidspark/e76ce0b0-7f29-45a7-ae42-e110fac401b8/edit?viewport_loc=-923%2C-602%2C1380%2C1313%2C0_0&invitationId=inv_f5e39814-dfb6-4755-9647-ad31873c111e
