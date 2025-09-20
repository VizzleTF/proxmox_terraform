terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

locals {
  # Filter only enabled VMs
  enabled_vms = {
    for key, vm in var.vms_config.vms : key => vm
    if vm.enabled
  }
}

resource "proxmox_virtual_environment_vm" "vms" {
  for_each = local.enabled_vms

  name        = each.key
  tags        = concat(var.vms_config.tags, coalesce(each.value.tags, []))
  node_name   = coalesce(each.value.node_name, var.vms_config.global.node_name)
  vm_id       = each.value.vm_id
  boot_order  = coalesce(each.value.boot_order, var.vms_config.global.boot_order)
  description = each.value.description

  pool_id = try(coalesce(each.value.pool_id, var.vms_config.global.pool_id), null)

  agent { enabled = true }
  
  cpu {
    cores = coalesce(each.value.cores, var.vms_config.global.cores)
    type  = coalesce(each.value.cpu_type, var.vms_config.global.cpu_type)
  }
  
  memory { 
    dedicated = coalesce(each.value.ram, var.vms_config.global.ram)
  }
  
  startup {
    order    = coalesce(each.value.startup_order, var.vms_config.global.startup_order)
    up_delay = coalesce(each.value.startup_up_delay, var.vms_config.global.startup_up_delay)
  }
  
  disk {
    datastore_id = coalesce(each.value.datastore_id, var.vms_config.global.datastore_id)
    file_id      = each.value.image_file
    interface    = "sata0"
    size         = coalesce(each.value.disk_size, var.vms_config.global.disk_size)
  }
  
  initialization {
    dns {
      servers = coalesce(each.value.dns_servers, var.vms_config.global.dns_servers)
    }
    ip_config {
      ipv4 {
        address = each.value.address
        gateway = coalesce(each.value.gateway, var.vms_config.global.gateway)
      }
    }
    user_account {
      keys     = each.value.pc_public_key != null ? [trimspace(each.value.pc_public_key)] : []
      password = each.value.vm_password
      username = "root"
    }
  }

  dynamic "usb" {
    for_each = each.value.usb != null ? [each.value.usb] : []
    content {
      host    = usb.value.host
      mapping = usb.value.mapping
      usb3    = usb.value.usb3
    }
  }

  network_device { 
    bridge = coalesce(each.value.network_bridge, var.vms_config.global.network_bridge)
  }
  
  operating_system { 
    type = coalesce(each.value.os_type, var.vms_config.global.os_type)
  }
  
  lifecycle {
    ignore_changes = [
      cpu["architecture"],
      initialization[0].dns[0].servers,
      initialization[0].user_account[0].keys,
    ]
  }
}

output "vm_ids" {
  description = "Map of VM names to their IDs"
  value = {
    for key, vm in proxmox_virtual_environment_vm.vms : key => vm.id
  }
}