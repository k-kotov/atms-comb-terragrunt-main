module "app" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.1"

  name = "${var.name_prefix}-app"

  ami_ssm_parameter  = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
  ignore_ami_changes = true

  instance_type = var.app_instance_type

  get_password_data = true
  key_name          = aws_key_pair.this.key_name

  subnet_id              = element(var.private_subnet_ids, random_integer.this.result)
  vpc_security_group_ids = [module.instance_sg.security_group_id]

  metadata_options = {
    "http_endpoint" : "enabled",
    "http_put_response_hop_limit" : 1,
    "http_tokens" : "required"
  }

  create_iam_instance_profile = true
  iam_role_name               = "${var.name_prefix}-app-ec2-role"
  iam_role_use_name_prefix    = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  volume_tags = var.tags

  tags = var.tags
}

resource "random_integer" "this" {
  min = 0
  max = length(var.private_subnet_ids) - 1
}

module "instance_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name            = "${var.name_prefix}-app"
  use_name_prefix = true

  description = "Security Group for App Instance"

  vpc_id = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "rdp-tcp"
      source_security_group_id = var.twingate_security_group_id
    },
    {
      rule                     = "rdp-udp"
      source_security_group_id = var.twingate_security_group_id
    },
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb.security_group_id
    }
  ]
  egress_rules = ["all-all"] # TODO: restrict egress traffic to ALB, Twingate, and DB

  tags = var.tags
}

resource "aws_key_pair" "this" {
  key_name   = "${var.name_prefix}-app-key"
  public_key = tls_private_key.this.public_key_openssh

  tags = var.tags
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_secretsmanager_secret" "this" {
  name_prefix             = "${var.name_prefix}-app-instance"
  recovery_window_in_days = 7

  tags = var.tags
}

locals {
  secrets = {
    username    = ".\\Administrator"
    password    = rsadecrypt(module.app.password_data, tls_private_key.this.private_key_pem)
    private_key = tls_private_key.this.private_key_pem
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(local.secrets)
}
