resource "aws_eks_addon" "csi_driver" {
  cluster_name             = aws_eks_cluster.aws_eks.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.ebs_csi_driver_version
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
}