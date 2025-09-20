locals {
  images_config = yamldecode(file("./configs/images.yaml"))
}

module "cloud_images" {
  source = "./modules/cloud_images"

  images_config = local.images_config
}