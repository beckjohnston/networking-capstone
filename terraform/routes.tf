
resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "app-igw"
  }
}


resource "aws_internet_gateway" "observability" {
  vpc_id = aws_vpc.observability.id

  tags = {
    Name = "observability-igw"
  }
}


resource "aws_internet_gateway" "network" {
  vpc_id = aws_vpc.network.id

  tags = {
    Name = "network-igw"
  }
}


resource "aws_route_table" "app_public" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }

  tags = {
    Name = "app-public-route"
  }
}


resource "aws_route_table_association" "app_public" {
  subnet_id      = aws_subnet.app_public.id
  route_table_id = aws_route_table.app_public.id
}


resource "aws_route_table" "obs_public" {
  vpc_id = aws_vpc.observability.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.observability.id
  }

  tags = {
    Name = "observability-public-route"
  }
}


resource "aws_route_table_association" "obs_public" {
  subnet_id      = aws_subnet.obs_public.id
  route_table_id = aws_route_table.obs_public.id
}


resource "aws_route_table" "network_public" {
  vpc_id = aws_vpc.network.id

  tags = {
    Name = "network-public-route"
  }
}

resource "aws_route" "network_public_default" {
  route_table_id         = aws_route_table.network_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.network.id
}


resource "aws_route_table_association" "network_public" {
  subnet_id      = aws_subnet.network_public.id
  route_table_id = aws_route_table.network_public.id
}
