resource "aws_ec2_transit_gateway" "main" {

  description = "networking-capstone-transit-gateway"

  amazon_side_asn = 64512

  default_route_table_association = "disable"

  default_route_table_propagation = "disable"

  tags = {
    Name = "capstone-tgw"
  }
}
