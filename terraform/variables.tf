variable "aws_region" {
  description = "AWS region to provision all resources in."
  type        = string
  default     = "eu-west-3"
}

variable "aws_profile" {
  description = "Local AWS CLI profile used by Terraform."
  type        = string
  default     = "default"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones the VPC subnets are spread across."
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets (one per AZ)."
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets (one per AZ)."
  type        = list(string)
  default     = ["10.0.64.0/19", "10.0.96.0/19"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "eks-cluster-weather"
}

variable "node_instance_type" {
  description = "EC2 instance type used by the EKS managed node group."
  type        = string
  default     = "t3.small"
}

variable "node_group_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 2
}

variable "node_group_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 1
}

variable "ebs_csi_driver_version" {
  description = "Version of the aws-ebs-csi-driver EKS add-on."
  type        = string
  default     = "v1.21.0-eksbuild.1"
}

variable "environment" {
  description = "Environment tag applied to networking resources."
  type        = string
  default     = "dev"
}

variable "cicd_iam_user_name" {
  description = "Name of the IAM user used by the CI/CD pipeline to access the cluster."
  type        = string
  default     = "gitlab"
}
