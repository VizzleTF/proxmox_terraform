module "talos_configs" {
  source = "./modules/talos_configs"
  
  talos_configs = {
    global = {
      node_name    = "pve1"
      datastore_id = "memini"
    }
    configs = {
      "controlplane" = {
        enabled      = true
        content_type = "snippets"
        config_data  = file("/Users/ivan/_out/controlplane.yaml")
        file_name    = "talos-controlplane.yaml"
      }
      "worker" = {
        enabled      = true
        content_type = "snippets"
        config_data  = file("/Users/ivan/_out/worker.yaml")
        file_name    = "talos-worker.yaml"
      }
    }
  }
}