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
