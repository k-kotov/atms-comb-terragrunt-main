# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = find_in_parent_folders("_modules/twingate-ecs-connectors")
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

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  name_prefix     = dependency.vpc.outputs.name_prefix
  private_subnets = dependency.vpc.outputs.private_subnets
  vpc_id          = dependency.vpc.outputs.vpc_id
  tags            = dependency.vpc.outputs.tags

  twingate_remote_network_id   = dependency.twingate_remote_network.outputs.twingate_remote_network_id
  twingate_remote_network_name = "arcrecharge"
}