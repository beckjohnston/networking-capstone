output "app_vpc_id" {
  value = aws_vpc.app.id
}

output "observability_vpc_id" {
  value = aws_vpc.observability.id
}

output "network_vpc_id" {
  value = aws_vpc.network.id
}

output "app_public_subnet_id" {
  value = aws_subnet.app_public.id
}

output "app_private_1_subnet_id" {
  value = aws_subnet.app_private_1.id
}

output "app_private_2_subnet_id" {
  value = aws_subnet.app_private_2.id
}

output "observability_public_subnet_id" {
  value = aws_subnet.obs_public.id
}

output "observability_private_subnet_id" {
  value = aws_subnet.obs_private.id
}

output "network_public_subnet_id" {
  value = aws_subnet.network_public.id
}


output "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  value       = aws_security_group.bastion.id
}

output "app_security_group_id" {
  description = "Security group ID for private application servers"
  value       = aws_security_group.app.id
}

output "grafana_security_group_id" {
  description = "Security group ID for Grafana"
  value       = aws_security_group.grafana.id
}

output "prometheus_security_group_id" {
  description = "Security group ID for Prometheus"
  value       = aws_security_group.prometheus.id
}

output "router_security_group_id" {
  description = "Security group ID for router"
  value       = aws_security_group.router.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "app_private_1_ip" {
  value = aws_instance.app_private_1.private_ip
}

output "app_private_2_ip" {
  value = aws_instance.app_private_2.private_ip
}

output "grafana_public_ip" {
  value = aws_instance.grafana.public_ip
}

output "prometheus_private_ip" {
  value = aws_instance.prometheus.private_ip
}

output "router_public_ip" {
  value = aws_instance.router.public_ip
}

output "transit_gateway_id" {

  value = aws_ec2_transit_gateway.main.id
}


output "transit_gateway_asn" {

  value = aws_ec2_transit_gateway.main.amazon_side_asn
}
