############################################################
# Get the available availability zones
############################################################

data "aws_availability_zones" "available" {}

############################################################
# Get a random ID that will be used for naming
# of the VPC resources.
############################################################

resource "random_id" "name" {
  byte_length = 4
}

locals {
  tags = {
    Environment = var.environment
    Client      = var.client
    Project     = "recharge"
    Component   = "vpc"
    uid         = random_id.name.hex
  }

  name_prefix = "atms-${var.environment}-${random_id.name.hex}"

  vpc_name     = local.name_prefix
  cluster_name = local.name_prefix

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # Make sure subnets are big enough for prefix delegation, this lets them hold 64 /28 blocks each
  cidr = "10.${var.cird_second_octet}.0.0/16"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = local.vpc_name
  cidr = local.cidr

  ############################################################
  # Configure logging
  ############################################################

  enable_flow_log                                 = true
  create_flow_log_cloudwatch_iam_role             = true
  create_flow_log_cloudwatch_log_group            = true
  flow_log_cloudwatch_log_group_retention_in_days = 30

  vpc_flow_log_iam_role_name                = "${local.name_prefix}-flow-logs"
  flow_log_cloudwatch_log_group_name_prefix = "/arc/${var.project}/${var.environment}/"

  ############################################################
  # Configure DHCP to support future private Route53 zones
  ############################################################

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_dhcp_options              = var.enable_dhcp_options
  dhcp_options_domain_name         = var.dhcp_options_domain_name
  dhcp_options_domain_name_servers = var.dhcp_options_domain_name_servers

  ############################################################
  # Setup NAT Gateways to either be single or per AZ
  ############################################################

  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = !var.single_nat_gateway && var.one_nat_gateway_per_az

  azs = local.azs

  ############################################################
  #  Setup private, public, intra, and database subnets
  ############################################################

  private_subnets       = [for k, v in local.azs : cidrsubnet(local.cidr, 4, k)]
  private_subnet_suffix = "private"
  private_subnet_tags = {
    "Name"                                        = "${local.name_prefix}-private"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
    "karpenter.sh/discovery"                      = "${local.cluster_name}"
    "Tier"                                        = "private"
  }
  private_route_table_tags = {
    "Name" = "${local.name_prefix}-private"
    "Tier" = "private"
  }

  # Public subnets will likely exclusively be used for ALBs/NLBs
  public_subnets       = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k + 48)]
  public_subnet_suffix = "public"
  public_subnet_tags = {
    "Name"                                        = "${local.name_prefix}-public"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
    "Tier"                                        = "public"
  }
  public_route_table_tags = {
    "Name" = "${local.name_prefix}-public"
    "Tier" = "public"
  }

  # Intra subnets will likely only be used for EKS control plane
  intra_subnets       = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k + 52)]
  intra_subnet_suffix = "intra"
  intra_subnet_tags = {
    "Name" = "${local.name_prefix}-intra"
    "Tier" = "intra"
  }

  # The database subnets will be used for ElastiCache and RDS
  create_database_subnet_group = true

  database_subnets       = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k + 56)]
  database_subnet_suffix = "database"
  database_subnet_tags = {
    "Name" = "${local.name_prefix}-database"
    "Tier" = "database"
  }
  database_route_table_tags = {
    "Name" = "${local.name_prefix}-database"
    "Tier" = "database"
  }

  tags = local.tags
}
