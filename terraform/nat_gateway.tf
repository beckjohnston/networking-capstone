resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "capstone-nat-eip"
  }
}

resource "aws_nat_gateway" "app" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.app_public.id

  depends_on = [
    aws_internet_gateway.app
  ]

  tags = {
    Name = "capstone-nat"
  }
}

# Elastic IP for the Observability NAT Gateway

resource "aws_eip" "observability_nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-observability-nat-eip"
  }
}

# NAT Gateway for the Observability private subnet

resource "aws_nat_gateway" "observability" {
  allocation_id = aws_eip.observability_nat.id
  subnet_id     = aws_subnet.obs_public.id

  depends_on = [
    aws_internet_gateway.observability
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-observability-nat"
  }
}
