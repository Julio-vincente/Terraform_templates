resource "aws_eks_cluster" "clusterDefault" {
  name     = "ClusterDefault"
  role_arn = var.k8s_role_arn

  vpc_config {
    subnet_ids = [
      var.subnet_pub1a,
      var.subnet_pub1b,
      var.subnet_priv1a,
      var.subnet_priv1b
    ]
  }
}

resource "random_id" "server" {
  byte_length = 10
}


resource "aws_eks_node_group" "default" {
  cluster_name = aws_eks_cluster.clusterDefault.name
  node_group_name = "default-node-groupo"
  node_role_arn = var.node-role-arn
  subnet_ids = [
    var.subnet_priv1a,
    var.subnet_priv1b
  ]

  scaling_config {
    desired_size = 2
    max_size = 2
    min_size = 2
  }

  instance_types = ["t3.medium"]
}