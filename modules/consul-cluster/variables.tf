# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name of the Consul cluster (e.g. consul). This variable is used to namespace all resources created by this module."
  type        = string
}

variable "user_data" {
  description = "A User Data script to execute while the server is booting. We recommend passing in a bash script that executes the run-consul script, which should have been installed in the Consul AMI by the install-consul module."
  type        = string
}

variable "image" {
    description = "The image ID that will be used to create the instance"
    type = string
}

variable "server_type" {
    description = "The Hetzner server type that will be used to create the instance"
    type = string
}

variable "location" {
    description = "The Hetzner location code that will be used to create the instance"
    type = string
}

variable "ssh_key" {
    description = "The public key that will be used to check ssh access"
    type = string
}

variable "network_id" {
    description = "network where the cluster will reside in"
    type = string
}

variable "private_subnet_id" {
    description = "subnet  where the cluster will reside in"
    type = string
}
variable "labels" {
    description = "Labels that are set at the instance"
    type = map(string)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_size" {
  description = "The number of nodes to have in the Consul cluster. We strongly recommended that you use either 3 or 5."
  type        = number
  default     = 3
}

variable "cluster_tag_key" {
  description = "Add a tag with this key and the value var.cluster_tag_value to each Instance. This can be used to automatically find other Consul nodes and form a cluster."
  type        = string
  default     = "consul-servers"
}

variable "cluster_tag_value" {
  description = "Add a tag with key var.cluster_tag_key and this value to each Instance. This can be used to automatically find other Consul nodes and form a cluster."
  type        = string
  default     = "0"
}

variable "associate_public_ip_address" {
  description = "If set to true, associate a public IP address with each Instance in the cluster."
  type        = bool
  default     = false
}

variable "root_volume_type" {
  description = "The type of volume. Must be one of: standard, gp2, or io1."
  type        = string
  default     = "standard"
}

variable "root_volume_size" {
  description = "The size, in GB, of the root EBS volume."
  type        = number
  default     = 50
}

variable "root_volume_delete_on_termination" {
  description = "Whether the volume should be destroyed on instance termination."
  type        = bool
  default     = true
}

variable "server_rpc_port" {
  description = "The port used by servers to handle incoming requests from other agents."
  type        = number
  default     = 8300
}

variable "cli_rpc_port" {
  description = "The port used by all agents to handle RPC from the CLI."
  type        = number
  default     = 8400
}

variable "serf_lan_port" {
  description = "The port used to handle gossip in the LAN. Required by all agents."
  type        = number
  default     = 8301
}

variable "serf_wan_port" {
  description = "The port used by servers to gossip over the WAN to other servers."
  type        = number
  default     = 8302
}

variable "http_api_port" {
  description = "The port used by clients to talk to the HTTP API"
  type        = number
  default     = 8500
}

variable "dns_port" {
  description = "The port used to resolve DNS queries."
  type        = number
  default     = 8600
}

variable "ssh_port" {
  description = "The port used for SSH connections"
  type        = number
  default     = 22
}
