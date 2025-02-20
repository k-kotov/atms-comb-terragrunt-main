# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = find_in_parent_folders("_modules/comb-infra")
}

include "vpc" {
  path           = find_in_parent_folders("/_dependency-blocks/vpc.hcl")
  expose         = true
  merge_strategy = "deep"
}

include "twingate_remote_network" {
  path           = find_in_parent_folders("_dependency-blocks/twingate-remote-network.hcl")
  expose         = true
  merge_strategy = "deep"
}

include "twingate_ecs_connectors" {
  path           = find_in_parent_folders("_dependency-blocks/twingate-ecs-connectors.hcl")
  expose         = true
  merge_strategy = "deep"
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  name_prefix        = dependency.vpc.outputs.name_prefix
  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  tags               = dependency.vpc.outputs.tags

  db_instance_class          = "db.t3.small"
  db_subnet_group            = dependency.vpc.outputs.database_subnet_group_name
  db_backup_retention_period = 7
  db_deletion_protection     = false

  route53_zone_id         = "Z069370018206ITRCYHSK"
  alb_route53_record_name = "atms-app.testing.arcadis-recharge.com"

  twingate_remote_network_id   = dependency.twingate_remote_network.outputs.twingate_remote_network_id
  twingate_remote_network_name = "arcrecharge"
  twingate_security_group_id   = dependency.twingate_ecs_connectors.outputs.twingate_security_group_id

  app_twingate_group_ids      = ["R3JvdXA6MjA4Mjk5"]
  database_twingate_group_ids = ["R3JvdXA6MjA4Mjk5"]
}