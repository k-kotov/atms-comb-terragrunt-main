resource "twingate_connector" "this" {
  for_each = var.private_subnets

  remote_network_id      = var.twingate_remote_network_id
  status_updates_enabled = true
}

resource "twingate_connector_tokens" "this" {
  for_each     = twingate_connector.this
  connector_id = each.value.id
}

resource "aws_secretsmanager_secret" "this" {
  for_each = twingate_connector_tokens.this

  name_prefix             = "${var.name_prefix}-${each.key}-twinagte-token"
  recovery_window_in_days = 7

  tags = var.tags
}

locals {
  twingate_secrets = { for k, v in twingate_connector_tokens.this : k => {
    access_token  = v.access_token
    refresh_token = v.refresh_token
  } }
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = local.twingate_secrets

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = jsonencode(each.value)
}

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.12.0"

  cluster_name = "${var.name_prefix}-twingate"

  cluster_settings = [
    {
      "name" : "containerInsights",
      "value" : "disabled"
    }
  ]

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  tags = var.tags
}

module "ecs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name            = "${var.name_prefix}-twingate"
  use_name_prefix = true
  description     = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id          = var.vpc_id

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = var.tags
}

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.12.0"

  for_each = var.private_subnets

  # Service
  name        = "${each.value.availability_zone}-connector"
  cluster_arn = module.ecs_cluster.arn

  runtime_platform = {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  task_exec_secret_arns = [aws_secretsmanager_secret.this[each.key].arn]

  # Container definition(s)
  container_definitions = {
    connector = {
      cpu    = 256
      memory = 512
      image  = "twingate/connector:latest"

      environment = [
        {
          name  = "TWINGATE_NETWORK"
          value = var.twingate_remote_network_name
        }
      ]

      secrets = [
        {
          name      = "TWINGATE_ACCESS_TOKEN"
          valueFrom = "${aws_secretsmanager_secret.this[each.key].arn}:access_token::"
        },
        {
          name      = "TWINGATE_REFRESH_TOKEN"
          valueFrom = "${aws_secretsmanager_secret.this[each.key].arn}:refresh_token::"
        }
      ]
    }
  }

  subnet_ids = [each.value.id]

  security_group_ids    = [module.ecs_sg.security_group_id]
  create_security_group = false

  tags = var.tags
}
