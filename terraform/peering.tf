# VPC 1 <-> VPC 2: allows Prometheus to scrape metrics from VPC 1 instances
resource "aws_vpc_peering_connection" "vpc1_vpc2" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true

  tags = {
    Name = "${var.project_name}-${var.environment}-peering-vpc1-vpc2"
  }
}

# VPC 1 <-> VPC 3: allows the router to reach VPC 1 app instances
resource "aws_vpc_peering_connection" "vpc1_vpc3" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc3.id
  auto_accept = true

  tags = {
    Name = "${var.project_name}-${var.environment}-peering-vpc1-vpc3"
  }
}