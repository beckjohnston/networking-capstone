# Networking-Capstone

## Project Overview

 - Creates an end-to-end pipeline to deploy and configure network infrastructure through Terraform. 
 - The Terraform implementation interfaces directly with AWS to create and destroy the necessary infrastructure components. 
      **See [Terraform](#terraform) for details on the the components provided**

 - The infrastructure is configured through Ansible, which implements the necessary configurations to all of the devices. 
      **See [Ansible](#ansible) for details on the playbooks provided**

 - All network deployment and configuration is triggered by pull request in the GitHub repository.
 - GitHub will automatically test the code for errors and update the existing network while still allowing for human oversight through required reviewers.
      **See [GitHub Actions](#github-actions) for detils on the workflows provided**

## Terraform

### Overview

The Terraform portion of the Networking Capstone provisions the complete AWS infrastructure used by the project. The environment is separated into three VPCs: an Application VPC for the bastion and private application servers, an Observability VPC for Grafana and Prometheus, and a Network VPC for the Cisco Catalyst 8000V router. Terraform also provisions the routing infrastructure connecting these environments, including Internet Gateways, a NAT Gateway, AWS Transit Gateway, Transit Gateway attachments, an AWS Customer Gateway, and an AWS Site-to-Site VPN used for BGP connectivity between AWS and the Cisco router. 

In addition to the network itself, Terraform manages the project's security groups, EC2 instances, Elastic IP addresses, SSH key resources, remote Terraform state, state locking, and AWS IAM resources used for GitHub OIDC authentication.

### Application VPC

The Application VPC uses the CIDR range 10.0.0.0/16 and contains one public subnet and two private subnets. The public subnet, 10.0.1.0/24,contains the bastion host and NAT Gateway. The private application subnets use 10.0.2.0/24 and 10.0.3.0/24 and each contain an Amazon Linux EC2 application instance. The bastion host is deployed in the public subnet with a public IP address and provides an administrative entry point into the application environment. The two application servers remain in private subnets and do not require public IP addresses. 

Terraform assigns the application instances the private_app role tag and places them behind the application security group. Terraform also provisions an Elastic IP and NAT Gateway in the Application VPC public subnet. Both private application subnets use a dedicated private route table whose default route points to the NAT Gateway. This allows the private instances to initiate outbound Internet connections while remaining inaccessible directly from the public Internet.

### Observability VPC

The Observability VPC uses the CIDR range 10.1.0.0/16. It contains a public subnet at 10.1.1.0/24 and a private subnet at 10.1.2.0/24. Terraform provisions the Grafana EC2 instance in the public subnet and the Prometheus EC2 instance in the private subnet. 

Grafana receives a public IP address and uses a dedicated security group that permits access to its web interface on TCP port 3000. Prometheus remains in the private subnet and uses its own security group. Separating these resources allows the user-facing monitoring interface and the internal monitoring service to have different network exposure.

### Network VPC and Cisco Catalyst 8000V

The Network VPC uses the CIDR range 10.2.0.0/16, with the router infrastructure located in the 10.2.1.0/24 public subnet. Terraform provisions a Cisco Catalyst 8000V EC2 instance using the Cisco Marketplace AMI ami-0be014c32727a2444 and the c5.large instance type. The Catalyst router is tagged with Name = catalyst-router and Role = router. Source/destination checking is disabled on the router so AWS permits the instance to forward packets rather than treating it only as a normal EC2 endpoint. 

Terraform also creates and attaches a secondary network interface at device index 1, with source/destinationchecking disabled on that interface as well. A dedicated Elastic IP is allocated and associated with the Catalyst instance. This gives the router a stable public endpoint and allows the same address to be referenced by the AWS Customer Gateway resource used for the VPN connection.

### Internet and Private Routing

Terraform provisions an Internet Gateway for each of the three VPCs. The Application, Observability, and Network public route tables each use their respective Internet Gateway as the destination for the 0.0.0.0/0 default route. This provides Internet connectivity to resources located in the public subnets. 

The private Application VPC subnets use a separate route table. Instead of routing 0.0.0.0/0 directly to an Internet Gateway, this route table points to the NAT Gateway in the public subnet. The two private application subnets are associated with this private route table, allowing outbound connectivity while preserving their private addressing.

### AWS Transit Gateway

Terraform provisions an AWS Transit Gateway to act as the centralized AWS routing layer for the project. The Transit Gateway uses Amazon-side ASN 64512. Default Transit Gateway route-table association and propagation are disabled so that the project's associations and route propagation are explicitly controlled by Terraform.

A dedicated Transit Gateway route table is created and used for the project. Terraform creates VPC attachments for the Application, Observability, and Network VPCs. The Application attachment uses both private application subnets, the Observability attachment uses the private observability subnet, and the Network attachment uses the subnet containing the Catalyst routing infrastructure.

Each VPC attachment is associated with the dedicated Transit Gateway route table. Route propagation is also enabled for the three VPC attachments so their networks can be represented in the Transit Gateway routing environment.

### Customer Gateway, Site-to-Site VPN, and BGP Infrastructure

Terraform creates an AWS Customer Gateway representing the CiscoCatalyst 8000V. The Customer Gateway uses the Catalyst router's ElasticIP as its endpoint and uses BGP ASN 64525. The AWS Transit Gatewayuses ASN 64512, creating the two autonomous systems required for theproject's eBGP relationship.

Terraform then provisions an AWS Site-to-Site VPN between the CiscoCustomer Gateway and the AWS Transit Gateway. The VPN is configured for dynamic routing rather than static routes. Its Transit Gateway attachment is also configured for route propagation into the project's Transit Gateway route table.

Two VPN tunnel networks are defined in Terraform. Tunnel 1 uses169.254.185.68/30, with 169.254.185.69 representing the AWS side and 169.254.185.70 representing the Cisco side. Tunnel 2 uses 169.254.232.88/30, with 169.254.232.89 representing the AWS side and 169.254.232.90 representing the Cisco side. These addresses are point-to-point tunnel addresses used for the BGP relationship and are separate from the three VPC address ranges.

This infrastructure gives the project a Terraform-managed path from the Cisco Catalyst router through the Site-to-Site VPN to AWS Transit Gateway, while also connecting all three project VPCs to the Transit Gateway.

### Security Groups

Terraform creates separate security groups for the major infrastructure roles. The bastion security group permits SSH access and outbound connectivity. The application security group allows SSH access from the bastion and permits TCP port 9100 traffic used by the application's monitoring architecture. Grafana has a dedicated security group that permits TCP port 3000, while Prometheus has its own rules for monitoring-related traffic.

The Cisco router uses a dedicated router security group. It permits SSH on TCP port 22 and BGP on TCP port 179, with outbound traffic permitted. Together with disabled EC2 source/destination checking, these rules allow the Catalyst instance to function as routing infrastructure rather than as a standard application host.

### SSH Key Infrastructure

Terraform defines a 4096-bit RSA private key using the TLS provider. The public portion of the generated key is registered with AWS as an EC2 keypair, while the private portion is stored in AWS Systems Manager Parameter Store as an encrypted Secure String.

The intended parameter path is /networking-capstone/dev/ssh-key. This design keeps the generated private key in AWS rather than storing it directly in the Git repository while allowing the EC2 infrastructure to use the corresponding public key.

### Terraform Remote State

Terraform uses an S3 backend for shared remote state. The state bucket is beck-networking-capstone-tfstate-2026, and the state object is stored at networking-capstone/terraform.tfstate. The S3 state infrastructure uses versioning, public-access blocking, server-side encryption, and deletion protection.

Terraform also uses the DynamoDB table networking-capstone-tf-locksfor state locking. The table uses LockID as its partition key. Together, S3 and DynamoDB provide centralized state storage and protection against simultaneous Terraform operations modifying the same state.

### AWS IAM and GitHub OIDC

Terraform provisions an AWS IAM OpenID Connect provider for GitHub usingtoken.actions.githubusercontent.com. It also creates the IAM role gha-networking-capstone-deploy, whose trust policy is restricted according to the configured GitHub repository.

The role has AWS PowerUserAccess attached. This infrastructure provides the AWS identity and permissions used by the project's Terraform pipeline without requiring permanent AWS access keys to be embedded directly in the repository configuration.

### Terraform Outputs

Terraform exposes the identifiers and addresses needed to reference the deployed infrastructure. These outputs include the three VPC IDs, subnet IDs, security group IDs, public and private EC2 addresses, NAT Gateway information, router management and inside-interface addresses, the router VPN Elastic IP, Transit Gateway ID and ASN, Customer Gateway ID,VPN connection ID, and the AWS-side and Cisco-side addresses for both VPN tunnels.

The BGP-related outputs are particularly important because they expose the values generated or managed by the AWS infrastructure. The Transit Gateway ASN identifies the AWS autonomous system, while the VPN tunnel outputs identify the AWS and Cisco BGP peer addresses for each tunnel. This allows the Terraform-managed AWS infrastructure to provide the network values required for configuration of the Cisco side without hard-coding deployed AWS resource identifiers elsewhere.

### Infrastructure Summary

Overall, the Terraform configuration creates the AWS foundation for the capstone as a three-VPC environment connected through centralized Transit Gateway routing. The Application VPC contains the bastion, private application instances, and NAT infrastructure; the Observability VPC contains Grafana and Prometheus; and the Network VPC contains the Cisco Catalyst 8000V. The Catalyst router is represented to AWS through a Customer Gateway and connects to the Transit Gateway through a dynamically routed Site-to-Site VPN with two BGP-capable tunnels.

Terraform also manages the supporting infrastructure required to operatethis environment, including Internet connectivity, route tables,security groups, Elastic IPs, SSH key resources, remote state, statelocking, and AWS IAM/OIDC resources. The result is an AWS networkingenvironment whose cloud infrastructure and routing components aredefined and maintained through Terraform.

### Network Infrastructure Diagram
<img width="1105" height="712" alt="Screenshot 2026-08-12 111610" src="https://github.com/user-attachments/assets/e4798d76-ef79-4615-9f24-942756e9bd08" />

## Ansible

### Inventory

 - The inventory file automatically changes based on the instances configured in the targeted AWS account
 - Need to query AWS for the targeted hosts based off of the tags provided at initialization of the instances.
 - Also possible to query through GitHub Action, however that has limited use.

### Playbooks

#### install_observability

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

#### verify_connectivity

 - Tests the connectivity between the public Bastion instance and the private application instances.
 ```
   ansible-playbook -i ansible/inventory/aws_ec2.yml ansible/playbooks/verify_connectivity.yml
```
 - Runs based on the inventory file that queries the AWS account associated with terraform

#### router_init
 - Runs the initial configuration onto the router.
 ```
   ansible-playbook \
      -i ansible/inventory/aws_ec2.yml \
      ansible/playbooks/router_config.yml
```  
 - Reloads at the end of the script, so it will take several minutes before the router is able to be accessed again

#### router_config
 - Imports and runs the router_config.j2 template onto the Cisco Catalyst 8000V router.

 - **MUST HAVE output.json LOCATED IN THE ansible/inventory/group_vars/all FOLDER** 
```
   terraform -chdir=terraform output -json > "${GITHUB_WORKSPACE}/ansible/inventory/group_vars/all/output.json"

   ansible-playbook \
      -i ansible/inventory/aws_ec2.yml \
      ansible/playbooks/router_config.yml
```  

 - Requires the following parameters from the terraform outputs to be able to run.
      - router_management_ip:             Private IP of the router
      - vpn_connection_id:                AWS id number for the VPN that was created
      - customer_gateway_id:              AWS id number assigned to the Customer Gateway that was created
      - router_vpn_public_ip:             Public IP that is used for the CGW and the end-point for the tunnel
      - vpn_tunnel1_router_inside_ip:     The Ip for the router side of the BGP tunnel
      - vpn_tunnel1_aws_inside_ip:        The IP for the AWS side of the BGP tunnel

 - See [BGP Documentation](#bgp-documentation) for details on the implementation of router_config.j2

### Roles

#### Grafana

 - Creates an instance of Grafana on the targeted node. Must be utilized with Prometheus.
 - Grafana password must be stored in GitHub secrets and called manually from GitHub Actions.
      ansible-playbook -i inventory_file playbook.yml -e "grafana_admin_password=password"

#### Prometheus

 - Creates an instance of Prometheus on the targeted node. 
 - Must be configured with Bastion to be able to scrape from VPC 1

#### Bastion

 - Creates a link between a preapproved node and the targeted node regardless of whether they are on the same VPC.
 - Needs configuration for keys generated by Terraform, session recording is an option if needed, but needs configured


## GitHub Actions

### ansible.yml
 - Triggered by a pull request on the main branch for automated deployment.
 - Manually triggered on the test branch for debugging.
 - Performs a dry run and posts output as a comment in the pull request.
 - Runs the ansible playbooks.

### terraform.yml
- Triggered by a pull request on the main branch for automated deployment.
- Manually triggered on the test branch for debugging.
- Takes input of plan, apply, or destroy to determine which terraform command to run.
- Posts terraform plan output as a comment in the pull request before applying changes.
- Runs terraform init and validate before planning or applying.
- Allows for a terraform destroy option for the clean deletion of resources.



Transit ASN: 64512

  
[pptx link](https://onedrive.live.com/:p:/g/personal/2dc866dcd3e1fe1d/IQCzgyaUMomDQZJtofj93lLDATa5H89nk-nIbJanmtNGYMY?rtime=_v-9K4Dt3kg&redeem=aHR0cHM6Ly8xZHJ2Lm1zL3AvYy8yZGM4NjZkY2QzZTFmZTFkL0lRQ3pneWFVTW9tRFFaSnRvZmo5M2xMREFUYTVIODluay1uSWJKYW5tdE5HWU1ZP2U9Q1ZyZFcz)

[diagram link](https://lucid.app/lucidspark/e76ce0b0-7f29-45a7-ae42-e110fac401b8/edit?viewport_loc=-923%2C-602%2C1380%2C1313%2C0_0&invitationId=inv_f5e39814-dfb6-4755-9647-ad31873c111e)

[Cisco Catalyst Transit VPC Documentation](https://www.cisco.com/c/en/us/td/docs/routers/C8000V/AWS/deploying-c8000v-on-amazon-web-services/deploy-transit-vpc-with-transit-gateway-aws.html#id_126960)
