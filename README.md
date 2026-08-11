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



# Terraform
## Overview

The Terraform portion of the Networking Capstone provisions the complete AWS infrastructure used by the project. The environment is separated into three VPCs: an Application VPC for the bastion and private application servers, an Observability VPC for Grafana and Prometheus, and a Network VPC for the Cisco Catalyst 8000V router. Terraform also provisions the routing infrastructure connecting these environments,including Internet Gateways, a NAT Gateway, AWS Transit Gateway, Transit Gateway attachments, an AWS Customer Gateway, and an AWS Site-to-Site VPN used for BGP connectivity between AWS and the Cisco router.

In addition to the network itself, Terraform manages the project's security groups, EC2 instances, Elastic IP addresses, SSH key resources, remote Terraform state, state locking, and AWS IAM resources used for GitHub OIDC authentication.

## Application VPC

The Application VPC uses the CIDR range 10.0.0.0/16 and contains one public subnet and two private subnets. The public subnet, 10.0.1.0/24, contains the bastion host and NAT Gateway. The private application subnets use 10.0.2.0/24 and 10.0.3.0/24 and each contain an Amazon Linux EC2 application instance.

The bastion host is deployed in the public subnet with a public IP address and provides an administrative entry point into the application environment. The two application servers remain in private subnets and do not require public IP addresses. Terraform assigns the application instances the private_app role tag and places them behind the application security group.

Terraform also provisions an Elastic IP and NAT Gateway in the Application VPC public subnet. Both private application subnets use a dedicated private route table whose default route points to the NATGateway. This allows the private instances to initiate outbound Internet connections while remaining inaccessible directly from the public Internet.

## Observability VPC

The Observability VPC uses the CIDR range 10.1.0.0/16. It contains a public subnet at 10.1.1.0/24 and a private subnet at 10.1.2.0/24.Terraform provisions the Grafana EC2 instance in the public subnet and the Prometheus EC2 instance in the private subnet.

Grafana receives a public IP address and uses a dedicated security group that permits access to its web interface on TCP port 3000. Prometheus remains in the private subnet and uses its own security group. Separating these resources allows the user-facing monitoring interface and the internal monitoring service to have different network exposure.

## Network VPC and Cisco Catalyst 8000V

The Network VPC uses the CIDR range 10.2.0.0/16, with the router infrastructure located in the 10.2.1.0/24 public subnet. Terraform provisions a Cisco Catalyst 8000V EC2 instance using the Cisco Marketplace AMI ami-0be014c32727a2444 and the c5.large instance type.

The Catalyst router is tagged with Name = catalyst-router and Role = router. Source/destination checking is disabled on the router so AWS permits the instance to forward packets rather than treating it only as a normal EC2 endpoint. Terraform also creates and attaches a secondary network interface at device index 1, with source/destination checking disabled on that interface as well.

A dedicated Elastic IP is allocated and associated with the Catalyst instance. This gives the router a stable public endpoint and allows the same address to be referenced by the AWS Customer Gateway resource used for the VPN connection.

## Internet and Private Routing

Terraform provisions an Internet Gateway for each of the three VPCs. The Application, Observability, and Network public route tables each use their respective Internet Gateway as the destination for the 0.0.0.0/0 default route. This provides Internet connectivity to resources located in the public subnets.

The private Application VPC subnets use a separate route table. Instead of routing 0.0.0.0/0 directly to an Internet Gateway, this route table points to the NAT Gateway in the public subnet. The two private application subnets are associated with this private route table, allowing outbound connectivity while preserving their private addressing.

## AWS Transit Gateway

Terraform provisions an AWS Transit Gateway to act as the centralized AWS routing layer for the project. The Transit Gateway uses Amazon-side ASN 64512. Default Transit Gateway route-table association and propagation are disabled so that the project's associations and route propagation are explicitly controlled by Terraform.

A dedicated Transit Gateway route table is created and used for the project. Terraform creates VPC attachments for the Application, Observability, and Network VPCs. The Application attachment uses both private application subnets, the Observability attachment uses the private observability subnet, and the Network attachment uses the subnet containing the Catalyst routing infrastructure.

Each VPC attachment is associated with the dedicated Transit Gatewayroute table. Route propagation is also enabled for the three VPCattachments so their networks can be represented in the Transit Gatewayrouting environment.

## Customer Gateway, Site-to-Site VPN, and BGP Infrastructure

Terraform creates an AWS Customer Gateway representing the CiscoCatalyst 8000V. The Customer Gateway uses the Catalyst router's ElasticIP as its endpoint and uses BGP ASN 64525. The AWS Transit Gatewayuses ASN 64512, creating the two autonomous systems required for the project's eBGP relationship.

Terraform then provisions an AWS Site-to-Site VPN between the CiscoCustomer Gateway and the AWS Transit Gateway. The VPN is configured for dynamic routing rather than static routes. Its Transit Gateway attachment is also configured for route propagation into the project's Transit Gateway route table.

Two VPN tunnel networks are defined in Terraform. Tunnel 1 uses 169.254.185.68/30, with 169.254.185.69 representing the AWS side and 169.254.185.70 representing the Cisco side. Tunnel 2 uses 169.254.232.88/30, with 169.254.232.89 representing the AWS side and 169.254.232.90 representing the Cisco side. These addresses are point-to-point tunnel addresses used for the BGP relationship and are separate from the three VPC address ranges.

This infrastructure gives the project a Terraform-managed path from the Cisco Catalyst router through the Site-to-Site VPN to AWS Transit Gateway, while also connecting all three project VPCs to the Transit Gateway.

## Security Groups

Terraform creates separate security groups for the major infrastructure roles. The bastion security group permits SSH access and outbound connectivity. The application security group allows SSH access from the bastion and permits TCP port 9100 traffic used by the application's monitoring architecture. Grafana has a dedicated security group that permits TCP port 3000, while Prometheus has its own rules for monitoring-related traffic.

The Cisco router uses a dedicated router security group. It permits SSH on TCP port 22 and BGP on TCP port 179, with outbound traffic permitted. Together with disabled EC2 source/destination checking, these rules allow the Catalyst instance to function as routing infrastructure rather than as a standard application host.

## SSH Key Infrastructure

Terraform defines a 4096-bit RSA private key using the TLS provider. The public portion of the generated key is registered with AWS as an EC2 key pair, while the private portion is stored in AWS Systems Manager Parameter Store as an encrypted Secure String.

The intended parameter path is /networking-capstone/dev/ssh-key. This design keeps the generated private key in AWS rather than storing it directly in the Git repository while allowing the EC2 infrastructure to use the corresponding public key.

## Terraform Remote State

Terraform uses an S3 backend for shared remote state. The state bucket is beck-networking-capstone-tfstate-2026, and the state object is stored at networking-capstone/terraform.tfstate. The S3 state infrastructure uses versioning, public-access blocking, server-side encryption, and deletion protection.

Terraform also uses the DynamoDB table networking-capstone-tf-locks for state locking. The table uses LockID as its partition key. Together, S3 and DynamoDB provide centralized state storage and protection against simultaneous Terraform operations modifying the same state.

## AWS IAM and GitHub OIDC

Terraform provisions an AWS IAM OpenID Connect provider for GitHub usingtoken.actions.githubusercontent.com. It also creates the IAM rolegha-networking-capstone-deploy, whose trust policy is restrictedaccording to the configured GitHub repository.

The role has AWS PowerUserAccess attached. This infrastructure provides the AWS identity and permissions used by the project's Terraform pipeline without requiring permanent AWS access keys to be embedded directly in the repository configuration.

## Terraform Outputs

Terraform exposes the identifiers and addresses needed to reference the deployed infrastructure. These outputs include the three VPC IDs, subnet IDs, security group IDs, public and private EC2 addresses, NAT Gateway information, router management and inside-interface addresses, the router VPN Elastic IP, Transit Gateway ID and ASN, Customer Gateway ID,VPN connection ID, and the AWS-side and Cisco-side addresses for both VPN tunnels.

The BGP-related outputs are particularly important because they expose the values generated or managed by the AWS infrastructure. The Transit Gateway ASN identifies the AWS autonomous system, while the VPN tunnel outputs identify the AWS and Cisco BGP peer addresses for each tunnel. This allows the Terraform-managed AWS infrastructure to provide the network values required for configuration of the Cisco side without hard-coding deployed AWS resource identifiers elsewhere.

## Infrastructure Summary

Overall, the Terraform configuration creates the AWS foundation for the capstone as a three-VPC environment connected through centralized Transit Gateway routing. The Application VPC contains the bastion, private application instances, and NAT infrastructure; the Observability VPC contains Grafana and Prometheus; and the Network VPC contains the Cisco Catalyst 8000V. The Catalyst router is represented to AWS through a Customer Gateway and connects to the Transit Gateway through a dynamically routed Site-to-Site VPN with two BGP-capable tunnels.

Terraform also manages the supporting infrastructure required to operate this environment, including Internet connectivity, route tables, security groups, Elastic IPs, SSH key resources, remote state, state locking, and AWS IAM/OIDC resources. The result is an AWS networking environment whose cloud infrastructure and routing components are defined and maintained through Terraform.
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

 - **MUST HAVE output.json LOCATED IN THE ansible/group_vars/all FOLDER** 
      terraform output -json > ./ansible/group_vars/all/output.json
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

#### terraform.yml
- Triggered by a pull request on the main branch for automated deployment.
- Manually triggered on the test branch for debugging with an option to run plan, apply, or destroy.
- Pull request automatically runs terraform init, validate, and plan and posts the plan as a comment in the pull request.
- An issue will be raised which must be approved by an authorized user before terraform apply will run. 
- Terraform apply will automatically deploy and update resources as needed using the AWS resources on the specified account. 
- Allows for a terraform destroy option for the clean deletion of resources.
  
#### ansible.yml
 - Triggered by a pull request on the main branch for automated deployment.
 - Manually triggered on the test branch for debugging.
 - Performs a dry run for each playbook and posts output as a comment in the pull request.
 - Runs the ansible playbooks verify_connectivity.yml, install_observability, and router_config respectively to update each node with the correct configuration.



Transit ASN: 64512

  
pptx link : https://onedrive.live.com/:p:/g/personal/2dc866dcd3e1fe1d/IQCzgyaUMomDQZJtofj93lLDATa5H89nk-nIbJanmtNGYMY?rtime=_v-9K4Dt3kg&redeem=aHR0cHM6Ly8xZHJ2Lm1zL3AvYy8yZGM4NjZkY2QzZTFmZTFkL0lRQ3pneWFVTW9tRFFaSnRvZmo5M2xMREFUYTVIODluay1uSWJKYW5tdE5HWU1ZP2U9Q1ZyZFcz

diagram link: https://lucid.app/lucidspark/e76ce0b0-7f29-45a7-ae42-e110fac401b8/edit?viewport_loc=-923%2C-602%2C1380%2C1313%2C0_0&invitationId=inv_f5e39814-dfb6-4755-9647-ad31873c111e
