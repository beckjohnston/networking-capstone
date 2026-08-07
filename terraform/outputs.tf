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
