resource "aws_network_interface" "router_inside" {
  subnet_id = aws_subnet.network_public.id

  security_groups = [
    aws_security_group.router.id
  ]

  source_dest_check = false

  tags = {
    Name = "catalyst-inside-interface"
  }
}

resource "aws_network_interface_attachment" "router_inside" {
  instance_id = aws_instance.router.id

  network_interface_id = aws_network_interface.router_inside.id

  device_index = 1
}
