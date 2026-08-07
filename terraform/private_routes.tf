resource "aws_route_table" "app_private" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "app-private-rt"
  }
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.app_private.id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.app.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.app_private_1.id
  route_table_id = aws_route_table.app_private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.app_private_2.id
  route_table_id = aws_route_table.app_private.id
}
