locals {
  system = jsondecode(file("assets/system.json"))
}

resource "tfe_workspace" "consul_cluster" {
  name  = format("%s_%s", 
                local.system["env_stage"],
                local.system["workspace"]
                )
  organization = local.system["tfc_organization"]
  queue_all_runs = false
}

resource "tfe_variable" "ws_access_token" {
    key          = "access_token"
    value        = ""
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "Workspace that created the Boundary Network"
    sensitive    = true
}

resource "tfe_variable" "ws_env_name" {
    key          = "env_name"
    value        = format("%s-%s", 
                    lookup(local.system, "env_name"),
                    random_pet.name.id
                    )
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "Name of the Component"
}


resource "tfe_variable" "ws_env_stage" {
    key          = "env_stage"
    value        = lookup(local.system, "env_stage")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "Stage of the Component"
}

resource "tfe_variable" "ws_location" {
    key          = "location"
    value        = lookup(local.system, "location")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "Location of the Component"
}

resource "tfe_variable" "ws_system_function" {
    key          = "system_function"
    value        = lookup(local.system, "system_function")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "System Function of the Component"
}

resource "tfe_variable" "ws_consul_image" {
    key          = "consul_image"
    value        = lookup(local.system, "consul_image")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "consul_image of the Component"
}

resource "tfe_variable" "ws_consul_type" {
    key          = "consul_type"
    value        = lookup(local.system, "consul_type")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "consul_type of the Component"
}

resource "tfe_variable" "ws_keyname" {
    key          = "keyname"
    value        = lookup(local.system, "keyname")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "keyname of the Component"
}

resource "tfe_variable" "ws_network_zone" {
    key          = "network_zone"
    value        = lookup(local.system, "network_zone")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "network_zone of the Component"
}

resource "tfe_variable" "ws_network_component" {
    key          = "network_component"
    value        = lookup(local.system, "network_component")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "Hetzner Network Component where the new component will reside in"
}

resource "tfe_variable" "ws_num_servers" {
    key          = "num_servers"
    value        = lookup(local.system, "num_servers")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "num_servers of the Component"
}

resource "tfe_variable" "ws_enable_gossip_encryption" {
    key          = "enable_gossip_encryption"
    value        = lookup(local.system, "enable_gossip_encryption")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "enable_gossip_encryption of the Component"
}

resource "tfe_variable" "ws_enable_rpc_encryption" {
    key          = "enable_rpc_encryption"
    value        = lookup(local.system, "enable_rpc_encryption")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "enable_rpc_encryption of the Component"
}

resource "tfe_variable" "ws_gossip_encryption_key" {
    key          = "gossip_encryption_key"
    value        = lookup(local.system, "gossip_encryption_key")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "gossip_encryption_key of the Component"
}

resource "tfe_variable" "ws_ca_path" {
    key          = "ca_path"
    value        = lookup(local.system, "ca_path")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "ca_path of the Component"
}

resource "tfe_variable" "ws_cert_file_path" {
    key          = "cert_file_path"
    value        = lookup(local.system, "cert_file_path")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "cert_file_path of the Component"
}

resource "tfe_variable" "ws_key_file_path" {
    key          = "key_file_path"
    value        = lookup(local.system, "key_file_path")
    category     = "terraform"
    workspace_id = tfe_workspace.consul_cluster.id
    description  = "key_file_path of the Component"
}
