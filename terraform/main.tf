terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
  required_version = ">= 0.13"
}

variable "access_token" {}
variable "env_name"  { }
variable "env_stage" { }
variable "location" { }
variable "system_function" {}
variable "consul_image" {}
variable "consul_type" {}
variable "keyname" {} 
variable "network_zone" {}
variable "network_component" {}

provider "hcloud" {
  token = var.access_token
}

data "terraform_remote_state" "network" {
  backend = "remote"
  config = {
    organization = "selfscrum"
    workspaces = {
      name = var.network_component
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONSUL SERVER NODES
# ---------------------------------------------------------------------------------------------------------------------

module "consul_servers" {
  source = "../modules/consul-cluster"
  cluster_name      = "${var.cluster_name}-server"
  cluster_size      = var.num_servers
  image             = var.consul_image
  server_type       = var.consul_type
  location          = var.location
  labels            = {
                      "Name"   = var.env_name
                      "Stage"  = var.env_stage
                      "CONSUL" = count.index
  }
  ssh_keys          = [ var.keyname ]
  network_id        = data.terraform_remote_state.network.outputs.network_id
  private_subnet_id = data.terraform_remote_state.network.outputs.private_subnet_id
  cluster_tag_key   = var.cluster_tag_key
  cluster_tag_value = var.cluster_name
  user_data         = data.template_file.user_data_server.rendered
}

# ---------------------------------------------------------------------------------------------------------------------
# THE MULTIPART/MIXED USER DATA SCRIPT THAT WILL RUN ON EACH CONSUL SERVER INSTANCE WHEN IT'S BOOTING
# This script will provide some basic hardening and configure and start Consul
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_server" {
  template = file("${path.module}/user-data-server.mm")

  vars = {
    cluster_tag_key          = var.cluster_tag_key
    cluster_tag_value        = var.cluster_name
    enable_gossip_encryption = var.enable_gossip_encryption
    gossip_encryption_key    = var.gossip_encryption_key
    enable_rpc_encryption    = var.enable_rpc_encryption
    ca_path                  = var.ca_path
    cert_file_path           = var.cert_file_path
    key_file_path            = var.key_file_path
  }
}

output "consul_servers_cluster_tag_key" {
  value = module.consul_servers.cluster_tag_key
}

output "consul_servers_cluster_tag_value" {
  value = module.consul_servers.cluster_tag_value
}
