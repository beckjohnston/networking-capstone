resource "aws_ec2_transit_gateway_vpc_attachment" "app" {

  transit_gateway_id = aws_ec2_transit_gateway.main.id

  vpc_id = aws_vpc.app.id

  subnet_ids = [
    aws_subnet.app_private_1.id,
    aws_subnet.app_private_2.id
  ]

  tags = {
    Name = "app-tgw-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "observability" {

  transit_gateway_id = aws_ec2_transit_gateway.main.id

  vpc_id = aws_vpc.observability.id

  subnet_ids = [
    aws_subnet.obs_private.id
  ]

  tags = {
    Name = "observability-tgw-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "network" {

  transit_gateway_id = aws_ec2_transit_gateway.main.id

  vpc_id = aws_vpc.network.id

  subnet_ids = [
    aws_subnet.network_public.id
  ]

  tags = {
    Name = "network-tgw-attachment"
  }
}
