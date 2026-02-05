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
  instance_types  = ["t3.xlarge","t3.2xlarge"]
  capacity_type   = "SPOT"

  scaling_config {
    desired_size = 2
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
    command = "rm -rf ~/.kube ; aws eks update-kubeconfig --name dev ; kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
  }
}



### DB EC2 Instances.

resource "aws_instance" "instances" {
  for_each      = var.components
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = {
    Name = each.key
  }

}

resource "aws_route53_record" "a-records" {
  for_each      = var.components
  zone_id = var.zone_id
  name    = "${each.key}-dev"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instances[each.key].private_ip]
}

resource "null_resource" "ansible" {

  depends_on = [
    aws_instance.instances,
    aws_route53_record.a-records
  ]


  for_each      = var.components

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ec2-user"
      password = "DevOps321"
      host     = aws_instance.instances[each.key].private_ip
    }

    inline = [
      "sudo dnf install ansible -y",
      #"sudo dnf install python3.13-pip -y",
      #"sudo pip3.11 install ansible",
      "ansible-pull -i localhost, -U https://github.com/raghudevopsb87/roboshop-ansible-templates.git main.yml -e component=${each.key} -e env=dev"
    ]

  }

}
