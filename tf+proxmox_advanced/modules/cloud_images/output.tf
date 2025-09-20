output "downloaded_image_files" {
  description = "List of downloaded image file names"
  value = [
    for key, image in proxmox_virtual_environment_download_file.cloud_images : image.file_name
  ]
}