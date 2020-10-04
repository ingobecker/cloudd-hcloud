terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.21.0"
    }
  }
}

provider "hcloud" {
  token = var.api_token
}

module "cloudd" {
  source = "github.com/ingobecker/cloudd"

  volume_dev = "/dev/sdb"
  root_dev   = "/dev/sda"
  context    = var.context
  user       = var.user
  ssh_key    = var.ssh_key
}

resource "hcloud_server" "cloudd" {
  name        = "cloudd"
  image       = "fedora-32"
  server_type = "cx11"
  location    = "nbg1"
  user_data   = module.cloudd.cloud_init
}

resource "hcloud_volume_attachment" "cloudd" {
  volume_id = hcloud_volume.cloudd.id
  server_id = hcloud_server.cloudd.id
  automount = false
}

resource "hcloud_volume" "cloudd" {
  name     = "cloudd"
  location = "nbg1"
  size     = 10
}

data "external" "snapshot" {
  program = ["bash", "${path.module}/scripts/snapshot.sh"]
  query = {
    api_token = var.api_token
    server_id = hcloud_server.cloudd.id
    snap_name = var.name
  }
}

output "image_id" {
  value = data.external.snapshot.result.image_id
}
