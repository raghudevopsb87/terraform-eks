resource "aws_eks_addon" "pod-identity" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_eks_pod_identity_association" "example" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "default"
  service_account = "default"
  role_arn        = "arn:aws:iam::739561048503:role/test"
}
