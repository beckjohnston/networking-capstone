
# App VPC ID
output "app_vpc_id" {
  value = aws_vpc.app.id
}

# Observability VPC ID
output "observability_vpc_id" {
  value = aws_vpc.observability.id
}

# Network VPC ID containing the Cisco router
output "network_vpc_id" {
  value = aws_vpc.network.id
}

# App public subnet ID
output "app_public_subnet_id" {
  value = aws_subnet.app_public.id
}

# App private subnet 1 ID
output "app_private_1_subnet_id" {
  value = aws_subnet.app_private_1.id
}

# App private subnet 2 ID
output "app_private_2_subnet_id" {
  value = aws_subnet.app_private_2.id
}

# Observability public subnet ID
output "observability_public_subnet_id" {
  value = aws_subnet.obs_public.id
}

# Observability private subnet ID
output "observability_private_subnet_id" {
  value = aws_subnet.obs_private.id
}

# Network public subnet ID containing the Cisco router
output "network_public_subnet_id" {
  value = aws_subnet.network_public.id
}

# Bastion security group ID
output "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  value       = aws_security_group.bastion.id
}

# App security group ID
output "app_security_group_id" {
  description = "Security group ID for private application servers"
  value       = aws_security_group.app.id
}

# Grafana security group ID
output "grafana_security_group_id" {
  description = "Security group ID for Grafana"
  value       = aws_security_group.grafana.id
}

# Prometheus security group ID
output "prometheus_security_group_id" {
  description = "Security group ID for Prometheus"
  value       = aws_security_group.prometheus.id
}

# Cisco router security group ID
output "router_security_group_id" {
  description = "Security group ID for router"
  value       = aws_security_group.router.id
}

# Bastion public IP
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

# App private instance 1 private IP
output "app_private_1_ip" {
  value = aws_instance.app_private_1.private_ip
}

# App private instance 2 private IP
output "app_private_2_ip" {
  value = aws_instance.app_private_2.private_ip
}

# Grafana public IP
output "grafana_public_ip" {
  value = aws_instance.grafana.public_ip
}

# Prometheus private IP
output "prometheus_private_ip" {
  value = aws_instance.prometheus.private_ip
}

# Cisco router EC2 public IP
output "router_public_ip" {
  value = aws_instance.router.public_ip
}

# AWS Transit Gateway ID
output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.main.id
}

# AWS Transit Gateway BGP ASN
output "transit_gateway_asn" {
  value = aws_ec2_transit_gateway.main.amazon_side_asn
}

# NAT Gateway public Elastic IP
output "nat_gateway_public_ip" {
  value = aws_eip.nat.public_ip
}

# Public subnet containing the NAT Gateway
output "nat_gateway_public_subnet_id" {
  value = aws_subnet.app_public.id
}

# NAT Gateway ID
output "nat_gateway_id" {
  value = aws_nat_gateway.app.id
}

# Private route table using the NAT Gateway
output "private_route_table_id" {
  value = aws_route_table.app_private.id
}

# NAT Gateway private IP
output "nat_gateway_private_ip" {
  value = aws_nat_gateway.app.private_ip
}

# Cisco router primary management/private IP
output "router_management_ip" {
  value = aws_instance.router.private_ip
}

# Cisco router secondary/inside interface private IP
output "router_inside_ip" {
  value = aws_network_interface.router_inside.private_ip
}

# Cisco router Elastic IP used as the VPN public endpoint
output "router_vpn_public_ip" {
  description = "Elastic public IP used by the Cisco Catalyst router for the VPN"
  value       = aws_eip.router.public_ip
}

# AWS Customer Gateway representing the Cisco router
output "customer_gateway_id" {
  description = "AWS Customer Gateway representing the Cisco router"
  value       = aws_customer_gateway.router.id
}

# AWS Site-to-Site VPN connection between Cisco router and TGW
output "vpn_connection_id" {
  description = "AWS Site-to-Site VPN connection between Catalyst and TGW"
  value       = aws_vpn_connection.router.id
}

# AWS-side BGP peer IP for VPN tunnel 1
output "vpn_tunnel1_aws_inside_ip" {
  description = "AWS-side BGP peer IP for VPN tunnel 1"
  value       = cidrhost(aws_vpn_connection.router.tunnel1_inside_cidr, 1)
}

# Cisco-side BGP IP for VPN tunnel 1
output "vpn_tunnel1_router_inside_ip" {
  description = "Cisco-side BGP IP for VPN tunnel 1"
  value       = cidrhost(aws_vpn_connection.router.tunnel1_inside_cidr, 2)
}

# AWS-side BGP peer IP for VPN tunnel 2
output "vpn_tunnel2_aws_inside_ip" {
  description = "AWS-side BGP peer IP for VPN tunnel 2"
  value       = cidrhost(aws_vpn_connection.router.tunnel2_inside_cidr, 1)
}

# Cisco-side BGP IP for VPN tunnel 2
output "vpn_tunnel2_router_inside_ip" {
  description = "Cisco-side BGP IP for VPN tunnel 2"
  value       = cidrhost(aws_vpn_connection.router.tunnel2_inside_cidr, 2)
}

# IPsec pre-shared key for VPN tunnel 1
output "vpn_tunnel1_preshared_key" {
  value = nonsensitive(aws_vpn_connection.router.tunnel1_preshared_key)
}

# IPsec pre-shared key for VPN tunnel 2
output "vpn_tunnel2_preshared_key" {
  value = nonsensitive(aws_vpn_connection.router.tunnel2_preshared_key)
}
