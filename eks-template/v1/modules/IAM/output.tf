output "k8s_role_arn" {
  value = aws_iam_role.k8s_role.arn
}

output "node-role-arn" {
  value = aws_iam_role.k8s_node_role.arn
}