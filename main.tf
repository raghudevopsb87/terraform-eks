terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}
resource "aws_eks_cluster" "main" {
  name     = var.env
  role_arn = aws_iam_role.cluster.arn
  version  = "1.34"
  vpc_config {
    subnet_ids = ["subnet-0ce8afa0dde986bc0", "subnet-0629872d39e431ea9"]
  }
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "main"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = ["subnet-0ce8afa0dde986bc0", "subnet-0629872d39e431ea9"]
  instance_types  = ["t3.xlarge"]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 10
  }

  update_config {
    max_unavailable = 1
  }
}

resource "aws_eks_access_entry" "workstation" {
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = "arn:aws:iam::739561048503:role/workstation-role"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "workstation" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::739561048503:role/workstation-role"

  access_scope {
    type       = "cluster"
  }
}

resource "null_resource" "kubeconfig" {

  depends_on = [aws_eks_node_group.main]

  triggers = {
    cluster = timestamp()
  }

  provisioner "local-exec" {
    command = "rm -rf ~/.kube ; aws eks update-kubeconfig --name dev"
  }
}