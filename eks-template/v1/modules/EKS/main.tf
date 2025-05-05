resource "aws_eks_cluster" "clusterDefault" {
  name                      = "ClusterDefault"
  role_arn                  = var.k8s_role_arn
  enabled_cluster_log_types = ["api", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids = [
      var.subnet_pub1a,
      var.subnet_pub1b,
      var.subnet_priv1a,
      var.subnet_priv1b
    ]


    security_group_ids = [
      var.sg-eks-cluster-id
    ]
  }
}

resource "aws_eks_node_group" "NodeDefault" {
  cluster_name    = aws_eks_cluster.clusterDefault.name
  node_group_name = "default-node-group"
  node_role_arn   = var.node-role-arn
  subnet_ids = [
    var.subnet_priv1a,
    var.subnet_priv1b
  ]

  # remote_access {
  #   ec2_ssh_key = aws_key_pair.eks_key.key_name
  #   source_security_group_ids = [var.sg-eks-cluster-id]
  # }

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t3.medium"]
}

# resource "aws_key_pair" "eks_key" {
#   key_name   = "eks-key"
#   public_key = file("")
# }
