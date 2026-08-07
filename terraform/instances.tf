# Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



# VPC 1 - Application

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.app_public.id

  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]

  key_name = var.key_name

  associate_public_ip_address = true

  tags = {
    Name = "bastion"
    Role = "bastion"
  }
}


resource "aws_instance" "app_private_1" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.app_private_1.id

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  key_name = var.key_name

  tags = {
    Name = "private-app-1"
    Role = "private_app"
  }
}


resource "aws_instance" "app_private_2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.app_private_2.id

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  key_name = var.key_name

  tags = {
    Name = "private-app-2"
    Role = "private_app"
  }
}



# VPC 2 - Observability


resource "aws_instance" "grafana" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.obs_public.id

  vpc_security_group_ids = [
    aws_security_group.grafana.id
  ]

  key_name = var.key_name

  associate_public_ip_address = true

  tags = {
    Name = "grafana"
    Role = "grafana"
  }
}


resource "aws_instance" "prometheus" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.obs_private.id

  vpc_security_group_ids = [
    aws_security_group.prometheus.id
  ]

  key_name = var.key_name

  tags = {
    Name = "prometheus"
    Role = "prometheus"
  }
}



# VPC 3 - Network Router


resource "aws_instance" "router" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id = aws_subnet.network_public.id

  vpc_security_group_ids = [
    aws_security_group.router.id
  ]

  key_name = var.key_name

  associate_public_ip_address = true

  tags = {
    Name = "router"
    Role = "router"
  }
}
