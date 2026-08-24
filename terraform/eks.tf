resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

module "weather-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "weather-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = var.environment
  }
}


resource "aws_eks_cluster" "aws_eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = module.weather-vpc.private_subnets
  }

  # API_AND_CONFIG_MAP enables aws_eks_access_entry (IAM-native cluster
  # access) below, alongside the legacy aws-auth ConfigMap approach, so
  # this doesn't break any access already configured directly in-cluster.
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = {
    Name = "EKS_weather"
  }
}

resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group-weather"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "node_weather"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = module.weather-vpc.private_subnets

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  instance_types = [var.node_instance_type]

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_user" "gitlab" {
  name = var.cicd_iam_user_name
}

resource "aws_iam_access_key" "gitlab" {
  user = aws_iam_user.gitlab.name
}

# Minimum AWS-side permission the CI/CD identity needs: enough to resolve
# cluster connection details for `aws eks update-kubeconfig`. Authorization
# inside the cluster is handled entirely by Kubernetes RBAC
# (k8s/roles/cicd-role.yaml), not by this IAM policy.
data "aws_iam_policy_document" "gitlab_eks_describe" {
  statement {
    actions   = ["eks:DescribeCluster"]
    resources = [aws_eks_cluster.aws_eks.arn]
  }
}

resource "aws_iam_user_policy" "gitlab_eks_describe" {
  name   = "eks-describe-cluster"
  user   = aws_iam_user.gitlab.name
  policy = data.aws_iam_policy_document.gitlab_eks_describe.json
}

# Maps the gitlab IAM user to the Kubernetes username "gitlab" via EKS's
# native access-entry mechanism, so it can authenticate to the cluster at
# all. Grants no Kubernetes permissions by itself — authorization still
# comes entirely from k8s/roles/cicd-role.yaml and cicd-rolebinding.yaml,
# which bind that same username to a least-privilege Role. Without this
# resource, the IAM user has no way to authenticate to the cluster
# regardless of what the Kubernetes RBAC objects say.
resource "aws_eks_access_entry" "gitlab" {
  cluster_name  = aws_eks_cluster.aws_eks.name
  principal_arn = aws_iam_user.gitlab.arn
  user_name     = var.cicd_iam_user_name
  type          = "STANDARD"
}
