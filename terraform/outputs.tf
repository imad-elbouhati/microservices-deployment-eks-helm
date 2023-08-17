output "eks_cluster_endpoint" {
  value = aws_eks_cluster.aws_eks.endpoint
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.aws_eks.certificate_authority
}

output "gitlab-access-key" {
  value = aws_iam_access_key.gitlab.id
}

output "gitlab-secret-key" {
  value = aws_iam_access_key.gitlab.secret
  sensitive = true
}