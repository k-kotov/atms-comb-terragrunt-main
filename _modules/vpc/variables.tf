############################################################
# Get Clent, Env, and Project variables, used for tagging
############################################################

variable "client" {
  description = "The client for which the resources are created"
  type        = string
}

variable "environment" {
  description = "The environment in which the resources are created"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "stg", "prg"], var.environment)
    error_message = "The environment value must be one of 'dev', 'qa', 'stg', 'prd'."
  }
}

variable "project" {
  description = "The project for which the resources are created"
  type        = string
}

############################################################
# Get the VPC module variables
############################################################

variable "cird_second_octet" {
  description = "The second octet of the CIDR block"
  type        = number
  default     = 0
}

variable "one_nat_gateway_per_az" {
  description = "Whether to create one NAT Gateway per AZ"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Whether to create a single NAT Gateway"
  type        = bool
  default     = true
}

variable "enable_dhcp_options" {
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}
