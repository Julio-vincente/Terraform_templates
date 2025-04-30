resource "aws_vpc" "default-vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = false
  enable_dns_support   = false
  tags = {
    Name = "alb-vpc"
  }
}

resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id            = aws_vpc.default-vpc.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr
  tags = {
    Name = "subnet-${each.key}"
    Type = each.value.type
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default-vpc.id
  tags = {
    Name = "IGW"
  }
}

resource "aws_eip" "ip_nat" {
  domain = "vpc"
  tags = {
    Name = "eip_nat"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.ip_nat.id
  subnet_id     = aws_subnet.subnets["pub-1a"].id
  tags = {
    Name = "NatGW"
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.default-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-routeTable"
  }
}

resource "aws_route_table" "priv_rt" {
  vpc_id = aws_vpc.default-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "private-routeTable"
  }
}

resource "aws_route_table_association" "ass_pub" {
  for_each = {
    "pub-1a" = aws_subnet.subnets["pub-1a"].id
    "pub-1b" = aws_subnet.subnets["pub-1b"].id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "ass_priv" {
  for_each = {
    "pub-1a" = aws_subnet.subnets["priv-1a"].id
    "pub-1b" = aws_subnet.subnets["priv-1b"].id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.priv_rt.id
}

resource "aws_security_group" "eks_sg" {
  name        = "ClusterSg"
  description = "aaaaaaaaaaa"
  vpc_id      = aws_vpc.default-vpc.id
}
