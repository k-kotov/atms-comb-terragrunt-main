locals {
  resources = {
    app = {
      name       = "${var.name_prefix}-app"
      address    = module.app.private_ip
      alias      = "app.${var.name_prefix}.stg.comb.atms"
      group_ids  = var.app_twingate_group_ids
      allow_icmp = true
      tcp_policy = {
        policy = "RESTRICTED"
        ports  = [3389]
      }
      udp_policy = {
        policy = "RESTRICTED"
        ports  = [3389]
      }
    }
    database = {
      name       = "${var.name_prefix}-database"
      address    = module.db.db_instance_address
      group_ids  = var.database_twingate_group_ids
      allow_icmp = false
      tcp_policy = {
        policy = "RESTRICTED"
        ports  = [1433]
      }
      udp_policy = {
        policy = "RESTRICTED"
        ports  = [1433]
      }
    }
  }
}

resource "twingate_resource" "this" {
  for_each          = { for resource in local.resources : resource.name => resource }
  name              = each.key
  address           = each.value.address
  remote_network_id = var.twingate_remote_network_id

  protocols = {
    allow_icmp = each.value.allow_icmp

    tcp = {
      policy = each.value.tcp_policy.policy
      ports  = try(each.value.tcp_policy.ports, null)
    }

    udp = {
      policy = each.value.udp_policy.policy
      ports  = try(each.value.udp_policy.ports, null)
    }
  }

  dynamic "access_group" {
    for_each = each.value.group_ids
    content {
      group_id = access_group.value
    }
  }
}
