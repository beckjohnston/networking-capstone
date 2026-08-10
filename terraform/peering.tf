# VPC 1 (Application) <-> VPC 2 (Observability)
resource "aws_vpc_peering_connection" "app_observability" {
  vpc_id      = aws_vpc.app.id
  peer_vpc_id = aws_vpc.observability.id
  auto_accept = true

  tags = {
    Name = "${var.project_name}-${var.environment}-peering-app-observability"
  }
}

# Private route table for the Observability private subnet
resource "aws_route_table" "obs_private" {
  vpc_id = aws_vpc.observability.id

  tags = {
    Name = "observability-private-rt"
  }
}

# Associate the Prometheus subnet with its private route table
resource "aws_route_table_association" "obs_private" {
  subnet_id      = aws_subnet.obs_private.id
  route_table_id = aws_route_table.obs_private.id
}

# App private subnets can reach the Observability VPC
resource "aws_route" "app_to_observability" {
  route_table_id            = aws_route_table.app_private.id
  destination_cidr_block    = "10.1.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.app_observability.id
}

# Prometheus/Observability can reach the Application VPC
resource "aws_route" "observability_to_app" {
  route_table_id            = aws_route_table.obs_private.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.app_observability.id
}


# VPC 1 (Application) <-> VPC 3 (Network/Cisco)
resource "aws_vpc_peering_connection" "app_network" {
  vpc_id      = aws_vpc.app.id
  peer_vpc_id = aws_vpc.network.id
  auto_accept = true

  tags = {
    Name = "${var.project_name}-${var.environment}-peering-app-network"
  }
}

# App private subnets can reach the Network VPC
resource "aws_route" "app_to_network" {
  route_table_id            = aws_route_table.app_private.id
  destination_cidr_block    = "10.2.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.app_network.id
}

# Cisco/Network VPC can reach the Application VPC
resource "aws_route" "network_to_app" {
  route_table_id            = aws_route_table.network_public.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.app_network.id
}
