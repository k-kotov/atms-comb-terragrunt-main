variable "name_prefix" {
  description = "The prefix to apply to all resources in this module"
  type        = string
}

variable "client" {
  description = "The client for which the resources are created"
  type        = string
}

resource "twingate_remote_network" "this" {
  name     = "${var.client}-${var.name_prefix}"
  location = "AWS"
}

output "twingate_remote_network_id" {
  value = twingate_remote_network.this.id
}

output "twingate_remote_network_name" {
  value = twingate_remote_network.this.name
}
