# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = find_in_parent_folders("_modules/twingate-remote-network")
}

include "vpc" {
  path           = find_in_parent_folders("/_dependency-blocks/vpc.hcl")
  expose         = true
  merge_strategy = "deep"
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  name_prefix = dependency.vpc.outputs.name_prefix
}