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
variable "num_servers" {}
variable "enable_gossip_encryption" {}
variable "enable_rpc_encryption" {}
variable "gossip_encryption_key" {}
variable "ca_path" {}
variable "cert_file_path" {}
variable "key_file_path" {}

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
  cluster_name      = format("%s-%s-server",var.env_stage, var.env_name)
  cluster_size      = var.num_servers
  image             = var.consul_image
  server_type       = var.consul_type
  location          = var.location
  labels            = {
                      "Name"   = var.env_name
                      "Stage"  = var.env_stage
  }
  ssh_key           = var.keyname
  network_id        = data.terraform_remote_state.network.outputs.network_id
  private_subnet_id = data.terraform_remote_state.network.outputs.private_subnet_id
  user_data         = templatefile (
# ---------------------------------------------------------------------------------------------------------------------
# THE MULTIPART/MIXED USER DATA SCRIPT THAT WILL RUN ON EACH CONSUL SERVER INSTANCE WHEN IT'S BOOTING
# This script will provide some basic hardening and configure and start Consul
# ---------------------------------------------------------------------------------------------------------------------
                      "${path.module}/user-data-server.mm",
                        {
                        hcloud_token             = var.access_token,
                        cluster_tag_key          = var.env_name,
                        cluster_tag_value        = "0",
                        enable_gossip_encryption = var.enable_gossip_encryption,
                        gossip_encryption_key    = var.gossip_encryption_key,
                        enable_rpc_encryption    = var.enable_rpc_encryption,
                        ca_path                  = var.ca_path,
                        cert_file_path           = var.cert_file_path,
                        key_file_path            = var.key_file_path
                        }
                      )
}

output "consul_servers_cluster_tag_key" {
  value = module.consul_servers.cluster_tag_key
}

output "consul_servers_cluster_tag_value" {
  value = module.consul_servers.cluster_tag_value
}
