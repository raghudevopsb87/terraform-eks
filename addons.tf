resource "aws_eks_addon" "pod-identity" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_eks_addon" "external-dns" {
  depends_on = [aws_eks_addon.pod-identity]
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "external-dns"
}

resource "aws_eks_pod_identity_association" "external-dns" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "external-dns"
  service_account = "external-dns"
  role_arn        = aws_iam_role.external-dns.arn
}

resource "aws_eks_pod_identity_association" "cluster-autoscaler" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "default"
  service_account = "cluster-autoscaler-aws-cluster-autoscaler"
  role_arn        = aws_iam_role.cluster-autoscaler.arn
}


