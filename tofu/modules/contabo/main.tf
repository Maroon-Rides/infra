locals {
  // `cntb get images`; only used for the first boot, NixOS replaces it.
  ubuntu_image_id = "d64d5c6c-9dda-4e38-8174-0ee282474d8a" // ubuntu-24.04

  // https://api.contabo.com/#tag/Instances/operation/createInstance
  product_id = "V153" // Cloud VPS 4
  region     = "US-central"
}

resource "contabo_secret" "bwees_ssh" {
  name  = "bwees"
  type  = "ssh"
  value = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJr7fOsF74yPo/dhdorxFhgnCURWPVDkIjeRz2md0Jzq"
}

resource "contabo_instance" "prod_server" {
  display_name = "prod-server"
  product_id   = local.product_id
  region       = local.region
  image_id     = local.ubuntu_image_id
  ssh_keys     = [contabo_secret.bwees_ssh.id]
  default_user = "root"

  lifecycle {
    // Destroying cancels the Contabo contract.
    prevent_destroy = true

    // Changing any of these reinstalls the OS.
    ignore_changes = [
      image_id,
      ssh_keys,
      user_data,
      root_password,
      default_user,
    ]
  }
}

module "nixos" {
  source = "../nixos-host"

  hostname    = "prod-server"
  target_host = contabo_instance.prod_server.ip_config[0].v4[0].ip
  instance_id = contabo_instance.prod_server.id
}
