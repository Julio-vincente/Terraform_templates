resource "aws_vpc" "egress-vpc" {
    cidr_block = "172.16.0.0/16"
    enable_dns_hostnames = false
    enable_dns_support = false
    tags = {
      Name = "alb-vpc"
    }
}

resource "aws_subnet" "subnets" {
    for_each = var.subnets

    vpc_id = aws_vpc.egress-vpc.id
    availability_zone = each.value.az
    cidr_block = each.value.cidr
    tags = {
      Name = "subnet-${each.key}"
      Type = each.value.type
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.egress-vpc.id
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
    subnet_id = aws_subnet.subnets["pub-1a"].id
    tags = {
      Name = "NatGW"
    }
}

resource "aws_route_table" "pub_rt" {
    vpc_id = aws_vpc.egress-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      Name = "public-routeTable"
    }
}

resource "aws_route_table" "priv_rt" {
    vpc_id = aws_vpc.egress-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
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

    subnet_id = each.value
    route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "ass_priv" {
    for_each = {
        "pub-1a" = aws_subnet.subnets["priv-1a"].id
        "pub-1b" = aws_subnet.subnets["priv-1b"].id
    }
    
    subnet_id = each.value
    route_table_id = aws_route_table.priv_rt.id
}

resource "aws_security_group" "alb_sg" {
    name = "loadBalancerSG"
    description = "allow https and https for internet and endpoint for services"
    vpc_id = aws_vpc.egress-vpc.id
}

resource "aws_security_group" "lambda_sg" {
    name = "LambdaSG"
    description = "Lambda SG for HTTP and HTTPs endpoint"
    vpc_id = aws_vpc.egress-vpc.id
}

resource "aws_security_group" "ec2_sg" {
    name = "EC2SG"
    description = "EC2 SG for HTTP and HTTPs endpoint"
    vpc_id = aws_vpc.egress-vpc.id
}

resource "aws_security_group" "ecs_sg" {
    name = "ContainerSG"
    description = "aaaaaaaaaaa"
    vpc_id = aws_vpc.egress-vpc.id
}

## 1 ALB
resource "aws_vpc_security_group_ingress_rule" "ingress_https_alb" {
    security_group_id = aws_security_group.alb_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    to_port = 443
}

resource "aws_vpc_security_group_ingress_rule" "ingress_http_alb" {
    security_group_id = aws_security_group.alb_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80
}

resource "aws_vpc_security_group_egress_rule" "egress_https_alb" {
    security_group_id = aws_security_group.alb_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    to_port = 443
}

resource "aws_vpc_security_group_egress_rule" "egress_http_alb" {
    security_group_id = aws_security_group.alb_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80
}

## 2 LAMBDA
resource "aws_vpc_security_group_ingress_rule" "ingress_https_lambda" {
    security_group_id = aws_security_group.lambda_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    to_port = 443
}

resource "aws_vpc_security_group_ingress_rule" "ingress_http_lambda" {
    security_group_id = aws_security_group.lambda_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80
}

resource "aws_vpc_security_group_egress_rule" "egress_https_lambda" {
    security_group_id = aws_security_group.lambda_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    to_port = 443
}

resource "aws_vpc_security_group_egress_rule" "egress_http_lambda" {
    security_group_id = aws_security_group.lambda_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80
}

## 3 EC2
resource "aws_vpc_security_group_ingress_rule" "ingress_https_ec2" {
    security_group_id = aws_security_group.ec2_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    to_port = 443
}

resource "aws_vpc_security_group_ingress_rule" "ingress_http_ec2" {
    security_group_id = aws_security_group.ec2_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80
}

resource "aws_vpc_security_group_egress_rule" "egress_https_ec2" {
    security_group_id = aws_security_group.ec2_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    to_port = 443
}

resource "aws_vpc_security_group_egress_rule" "egress_http_ec2" {
    security_group_id = aws_security_group.ec2_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80
}

## 4 ECS 
resource "aws_vpc_security_group_ingress_rule" "ingress_https_ecs" {
    security_group_id = aws_security_group.ecs_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    to_port = 443
}

resource "aws_vpc_security_group_ingress_rule" "ingress_http_ecs" {
    security_group_id = aws_security_group.ecs_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80
}

resource "aws_vpc_security_group_egress_rule" "egress_https_ecs" {
    security_group_id = aws_security_group.ecs_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    to_port = 443
}

resource "aws_vpc_security_group_egress_rule" "egress_http_ecs" {
    security_group_id = aws_security_group.ecs_sg.id
    ip_protocol = "tcp"
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80
}
## END

resource "aws_vpc_endpoint" "api_endpoint" {
  vpc_id = aws_vpc.egress-vpc.id
  service_name = "com.amazonaws.${var.region}.execute-api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.alb_sg.id,
    aws_security_group.lambda_sg.id,
    aws_security_group.ecs_sg.id,
    aws_security_group.ec2_sg.id
  ]

  subnet_ids = [
    aws_subnet.subnets["pub-1a"].id,
    aws_subnet.subnets["pub-1b"].id
  ]
}
