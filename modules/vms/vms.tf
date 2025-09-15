terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.vm_name
  tags        = var.tags
  node_name   = var.node_name
  vm_id       = var.vm_id
  boot_order  = ["sata0"]
  description = var.description

  pool_id = var.pool_id

  agent { enabled = true }
  cpu {
    cores = var.cores
    type  = "host"
  }
  memory { dedicated = var.ram }
  startup {
    order    = "2"
    up_delay = "5"
  }
  disk {
    datastore_id = var.datastore_id
    file_id      = var.image_file
    interface    = "sata0"
    size         = var.disk_size
  }
  initialization {
    dns {
      servers = var.dns_servers
    }
    ip_config {
      ipv4 {
        address = var.address
        gateway = var.gateway
      }
    }
    user_account {
      keys     = [trimspace(var.pc_public_key)]
      password = var.vm_password
      username = "root"
    }
  }

  dynamic "usb" {
    for_each = var.usb != null ? [var.usb] : []
    content {
      host    = usb.value.host
      mapping = usb.value.mapping
      usb3    = usb.value.usb3
    }
  }

  network_device { bridge = "vmbr0" }
  operating_system { type = "l26" }
  lifecycle {
    ignore_changes = [
      cpu["architecture"],
      initialization[0].dns[0].servers,
      initialization[0].user_account[0].keys,
    ]
  }
}

output "vm_id" {
  value = proxmox_virtual_environment_vm.vm.id
}