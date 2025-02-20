/*
|--------------------------------------------------------------------------
| Core values
|--------------------------------------------------------------------------
|
| These are compute values used by all dependent modules.
| 
*/

output "name_prefix" {
  description = "Name prefix to be used by all resources tied to this project."
  value       = local.name_prefix
}

output "tags" {
  description = "Base tags to apply to all resources tied to this project."
  value       = local.tags
}

output "uid" {
  description = "Randomly generated UID to allow for multiple instances of the same project."
  value       = random_id.name.hex
}

output "cluster_name" {
  description = "Computed EKS cluster name."
  value       = local.cluster_name
}

/*
|--------------------------------------------------------------------------
| VPC
|--------------------------------------------------------------------------
|
| Self explanatory outputs for the VPC module.
|
*/

output "azs" {
  value = module.vpc.azs
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "nat_public_ips" {
  value = module.vpc.nat_public_ips
}

/*
|--------------------------------------------------------------------------
| Subnets
|--------------------------------------------------------------------------
|
| These outputs are used by dependent modules to create r esources in
| the correct subnets. We output these to avoid data calls which will
| cause errors when running terragrunt apply-all.
|
*/

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "private_subnets" {
  value = {
    for subnet in module.vpc.private_subnet_objects : subnet.id => {
      availability_zone    = subnet.availability_zone
      availability_zone_id = subnet.availability_zone_id
      id                   = subnet.id
    }
  }
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "public_subnets" {
  value = {
    for subnet in module.vpc.public_subnet_objects : subnet.id => {
      availability_zone    = subnet.availability_zone
      availability_zone_id = subnet.availability_zone_id
      id                   = subnet.id
    }
  }
}

output "intra_subnet_ids" {
  value = module.vpc.intra_subnets
}

output "intra_subnets" {
  value = {
    for subnet in module.vpc.intra_subnet_objects : subnet.id => {
      availability_zone    = subnet.availability_zone
      availability_zone_id = subnet.availability_zone_id
      id                   = subnet.id
    }
  }
}

output "database_subnet_ids" {
  value = module.vpc.database_subnets
}

output "database_subnet_group" {
  value = module.vpc.database_subnet_group
}

output "database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}
