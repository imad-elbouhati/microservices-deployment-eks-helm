output "azs" {
  description = "Availability Zones"
  value   = module.vpc.azs
}

output "vpc_id" {
  description = "VPC ID"
  value   = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet ids"
  value = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet ids"
  value = module.vpc.public_subnets
}

