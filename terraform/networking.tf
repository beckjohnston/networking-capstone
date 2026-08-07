resource "aws_vpc" "app" {
  cidr_block           = var.vpc1_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "app-vpc"
  }
}

resource "aws_vpc" "observability" {
  cidr_block           = var.vpc2_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "observability-vpc"
  }
}

resource "aws_vpc" "network" {
  cidr_block           = var.vpc3_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "network-vpc"
  }
}
