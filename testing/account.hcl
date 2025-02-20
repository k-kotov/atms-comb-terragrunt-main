# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "testing"
  aws_account_id = "905418031387" # TODO: replace me with your AWS account ID!
  client         = "acme"
  project        = "atms"
}

inputs = {
  client = "acme"
}