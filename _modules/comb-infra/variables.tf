################################################################################
# Core
################################################################################

variable "name_prefix" {
  description = "A prefix to add to all resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

################################################################################
# VPC
################################################################################

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets"
  type        = list(string)
}

variable "twingate_remote_network_name" {
  description = "The Name of the Twingate remote network to connect to"
  type        = string
}

variable "twingate_remote_network_id" {
  description = "The ID of the Twingate remote network to connect to"
  type        = string
}

variable "twingate_security_group_id" {
  description = "The ID of the Twingate security group"
  type        = string
}

variable "app_twingate_group_ids" {
  description = "List of Twingate groups to grant access to the app EC2 instance"
  type        = list(string)
  default     = []
}

variable "database_twingate_group_ids" {
  description = "List of Twingate groups to grant access to the database RDS instance"
  type        = list(string)
  default     = []
}

################################################################################
# EC2
################################################################################

variable "app_instance_type" {
  description = "The instance type for the app"
  type        = string
  default     = "t3.medium"
}

################################################################################
# Database - Config
################################################################################

variable "db_instance_class" {
  description = "The instance class for the app database"
  type        = string
  default     = "db.t3.medium"
}

variable "db_subnet_group" {
  description = "The name of the subnet group for the app database"
  type        = string
}

variable "db_backup_retention_period" {
  description = "The number of days to retain backups for the app database"
  type        = number
  default     = 7
}

variable "db_performance_insights_enabled" {
  description = "Whether to enable Performance Insights for the app database"
  type        = bool
  default     = false
}

variable "db_deletion_protection" {
  description = "Whether to enable deletion protection for the app database"
  type        = bool
  default     = true
}

################################################################################
# Route53
################################################################################

variable "route53_zone_id" {
  description = "The ID of the Route53 zone"
  type        = string
}

variable "alb_route53_record_name" {
  description = "The name of the Route53 record for the ALB"
  type        = string
}
