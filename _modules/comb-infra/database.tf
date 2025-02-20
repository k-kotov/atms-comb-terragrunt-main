module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.10.0"

  identifier = "${var.name_prefix}-app-db"

  engine               = "sqlserver-ex"
  engine_version       = "15.00"
  family               = "sqlserver-ex-15.0" # DB parameter group
  major_engine_version = "15.00"             # DB option group
  instance_class       = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100

  # Encryption at rest is not available for DB instances running SQL Server Express Edition
  storage_encrypted = false

  username                             = "atms"
  manage_master_user_password_rotation = false
  port                                 = 1433

  # domain               = aws_directory_service_directory.demo.id
  # domain_iam_role_name = aws_iam_role.rds_ad_auth.name

  multi_az               = false
  db_subnet_group_name   = var.db_subnet_group
  vpc_security_group_ids = [module.db_sg.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["error"]
  create_cloudwatch_log_group     = true

  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = true
  deletion_protection     = var.db_deletion_protection

  performance_insights_enabled          = var.db_performance_insights_enabled
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60

  options                   = []
  create_db_parameter_group = false
  license_model             = "license-included"
  timezone                  = "GMT Standard Time"
  character_set_name        = "Latin1_General_CI_AS"

  tags = var.tags
}

module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.name_prefix}-app-db"
  description = "cbo security group"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_source_security_group_id = [
    {
      rule                     = "mssql-tcp"
      source_security_group_id = module.instance_sg.security_group_id
    },
    {
      rule                     = "mssql-tcp"
      source_security_group_id = var.twingate_security_group_id
    }
  ]

  tags = var.tags
}
