output "eks_cluster_endpoint" {
  value = aws_eks_cluster.aws_eks.endpoint
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.aws_eks.certificate_authority
}

# NOTE: this project provisions a static IAM access key for the CI/CD user.
# terraform/iam-oidc.tf already sets up an OIDC provider for IRSA (used by the
# EBS CSI driver); a production setup should federate CI/CD through OIDC as
# well instead of long-lived static credentials. See README "Production
# improvements" for details.
output "gitlab-access-key" {
  value     = aws_iam_access_key.gitlab.id
  sensitive = true
}

output "gitlab-secret-key" {
  value     = aws_iam_access_key.gitlab.secret
  sensitive = true
}