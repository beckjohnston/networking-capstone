
# Elastic IP for the Cisco Catalyst 8000V


resource "aws_eip" "router" {
  domain = "vpc"

  tags = {
    Name = "catalyst-router-eip"
  }
}

resource "aws_eip_association" "router" {
  instance_id   = aws_instance.router.id
  allocation_id = aws_eip.router.id
}


# Represents the Cisco Catalyst 8000V to AWS


resource "aws_customer_gateway" "router" {
  bgp_asn    = 64525
  ip_address = aws_eip.router.public_ip
  type       = "ipsec.1"

  tags = {
    Name = "catalyst-router-customer-gateway"
  }
}

# Site-to-Site VPN
# Catalyst 8000V <-> AWS Transit Gateway


resource "aws_vpn_connection" "router" {
  customer_gateway_id = aws_customer_gateway.router.id
  transit_gateway_id  = aws_ec2_transit_gateway.main.id

  type = "ipsec.1"

  static_routes_only = false

  tunnel1_inside_cidr = "169.254.185.68/30"
  tunnel2_inside_cidr = "169.254.232.88/30"

  tags = {
    Name = "catalyst-to-tgw-vpn"
  }
}
