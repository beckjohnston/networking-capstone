resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = {
    Name = "capstone-tgw-route-table"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "app" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route_table_association" "observability" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.observability.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route_table_association" "network" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "app" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "observability" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.observability.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "network" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}
