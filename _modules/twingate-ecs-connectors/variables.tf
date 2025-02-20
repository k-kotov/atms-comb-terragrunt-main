variable "name_prefix" {
  description = "The prefix to apply to all resources in this module"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy the Twingate connector into"
  type        = string
}

variable "private_subnets" {
  description = "The private subnets to deploy the Twingate connector into"
  type        = map(map(string))
}

variable "tags" {
  description = "A map of tags to apply to all resources in this module"
  type        = map(string)
}

variable "twingate_remote_network_id" {
  description = "The ID of the Twingate remote network to connect to"
  type        = string
}

variable "twingate_remote_network_name" {
  description = "The name of the Twingate remote network to connect to"
  type        = string
}
