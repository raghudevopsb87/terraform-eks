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

# resource "aws_launch_template" "main" {
#   name     = "main"
#
#   block_device_mappings {
#     device_name = "/dev/xvda"
#
#     ebs {
#       volume_size = 20
#       encrypted   = true
#     }
#   }
#
# }

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "main"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = ["subnet-0ce8afa0dde986bc0", "subnet-0629872d39e431ea9"]
  instance_types  = ["t3.xlarge"]

  # launch_template {
  #   name    = aws_launch_template.main.name
  #   version = "$Latest"
  # }

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 10
  }

  update_config {
    max_unavailable = 1
  }
}

