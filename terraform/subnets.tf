resource "aws_subnet" "app_public" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "app-public"
  }
}

resource "aws_subnet" "app_private_1" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "app-private-1"
  }
}

resource "aws_subnet" "app_private_2" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}c"

  tags = {
    Name = "app-private-2"
  }
}

resource "aws_subnet" "obs_public" {
  vpc_id                  = aws_vpc.observability.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "observability-public"
  }
}

resource "aws_subnet" "obs_private" {
  vpc_id            = aws_vpc.observability.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "observability-private"
  }
}

resource "aws_subnet" "network_public" {
  vpc_id                  = aws_vpc.network.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "network-public"
  }
}
