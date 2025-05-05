output "subnet_pub1a" {
  value = aws_subnet.subnets["pub-1a"].id
}

output "subnet_pub1b" {
  value = aws_subnet.subnets["pub-1b"].id
}

output "subnet_priv1a" {
  value = aws_subnet.subnets["priv-1a"].id
}

output "subnet_priv1b" {
  value = aws_subnet.subnets["priv-1a"].id
}

output "sg-eks-cluster-id" {
  value = aws_security_group.eks_sg.id
}
