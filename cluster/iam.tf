# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_iam_role" "demo-cluster" {
  name = local.cluster_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo-cluster.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "demo-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.demo-cluster.name
}

resource "aws_iam_role" "demo-node" {
  name = "${local.cluster_name}-node"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "demo-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.demo-node.name
}


######## Access Entry ##########
locals {
  eks_policies = {
    "admin_policy"  = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
    "cluster_admin" = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    "view_only"     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  }
}

resource "aws_eks_access_entry" "user" {
  cluster_name  = aws_eks_cluster.demo.name
  principal_arn = "arn:aws:iam::303952242443:role/aws_amie.wei_test-developer"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "user_policies" {
  for_each      = local.eks_policies
  cluster_name  = aws_eks_cluster.demo.name
  policy_arn    = each.value
  principal_arn = "arn:aws:iam::303952242443:role/aws_amie.wei_test-developer"

  access_scope {
    type       = "cluster"
    namespaces = []
  }

  depends_on = [aws_eks_access_entry.user]
}

