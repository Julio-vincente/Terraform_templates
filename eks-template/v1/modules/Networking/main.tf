resource "aws_vpc" "default-vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "eks-vpc"
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
  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster and nodes"
  vpc_id      = aws_vpc.default-vpc.id

  ingress {
    description = "Allow communication from EKS control plane"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow communication between nodes"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.default-vpc.cidr_block]
  }

  ingress {
    description = "Allow communication for worker nodes on HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.default-vpc.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}
