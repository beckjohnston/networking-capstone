# Elastic IP for the Observability NAT Gateway
resource "aws_eip" "observability_nat" {
  domain = "vpc"

  tags = {
    Name = "observability-nat-eip"
  }
}

# NAT Gateway in the Observability public subnet
resource "aws_nat_gateway" "observability" {
  allocation_id = aws_eip.observability_nat.id
  subnet_id     = aws_subnet.obs_public.id

  depends_on = [
    aws_internet_gateway.observability
  ]

  tags = {
    Name = "observability-nat"
  }
}

# Give the Observability private subnet outbound internet access
resource "aws_route" "observability_private_default" {
  route_table_id         = aws_route_table.obs_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.observability.id
}
