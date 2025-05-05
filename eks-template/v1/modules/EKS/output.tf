output "cluster_name" {
  value = aws_eks_cluster.clusterDefault.name
}

output "node_group_status" {
  value = aws_eks_node_group.NodeDefault.status
}
