# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "city-of-miami-beach"
  aws_account_id = "774305574209"
  client         = "comb"
  project        = "atms"
}

inputs = {
  client  = local.client
  project = local.project
}