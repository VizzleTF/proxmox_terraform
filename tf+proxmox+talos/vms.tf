locals {
  vms_config = yamldecode(file("./configs/vms.yaml"))
}

module "vms" {
  source = "./modules/vms"

  vms_config = local.vms_config
}