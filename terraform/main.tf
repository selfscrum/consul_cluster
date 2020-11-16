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


####
# Consul Server
#
#

resource "hcloud_server" "consul" {
  count = 3
  name        = format("%s-%s-CONSUL-%d", var.env_stage, var.env_name, count.index)
  image       = var.consul_image
  server_type = var.consul_type
  location    = var.location
  labels      = {
      "Name"     = var.env_name
      "Stage"    = var.env_stage
      "CONSUL" = count.index
  }
  ssh_keys    = [ var.keyname ]
  user_data   = <<-CONSUL_EOF
                #cloud-config
                users:
                  - name: desixma
                    groups: users, admin
                    sudo: ALL=(ALL) NOPASSWD:ALL
                    shell: /bin/bash
                    ssh_authorized_keys:
                      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDH6orvm7dzkp47YBEvxOk3cvvYR5io32OmbbnR96bGjlT7LZleL4oV/aozCAG4Axy6mgByULUsxG9l/JhmFa3zg0/rP9HrklX7oPNdAdN26QAquD6dgaZ3PFP7UXkkNaTTAmJcw02EaCNuCcGLGinKOi0LETN/K+BTfpL7Q5kUbWFnkDjJpiIjqZwNzBqU3G7OfbqpW+EbcCAouBkT+rE09lAUth5BXWgq7MhtF8LrfnIrrf0demkXqqYm2clXd5266M2LgCsu/LayMkO0ig4SH7DotgXxNeXLJQtu7E02rrxFTZuNvazQQ7TwBbZdDELmYB8BdRmTQjYZqMSw6zaf
                packages:
                  - fail2ban
                  - ufw
                package_update: true
                package_upgrade: true
                runcmd:
                  - printf "[sshd]\nenabled = true\nbanaction = iptables-multiport" > /etc/fail2ban/jail.local
                  - systemctl enable fail2ban
                  - ufw allow OpenSSH
                  - ufw enable
                  - sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
                  - sed -i -e '/^PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
                  - sed -i -e '/^X11Forwarding/s/^.*$/X11Forwarding no/' /etc/ssh/sshd_config
                  - sed -i -e '/^#MaxAuthTries/s/^.*$/MaxAuthTries 2/' /etc/ssh/sshd_config
                  - sed -i -e '/^#AllowTcpForwarding/s/^.*$/AllowTcpForwarding no/' /etc/ssh/sshd_config
                  - sed -i -e '/^#AllowAgentForwarding/s/^.*$/AllowAgentForwarding no/' /etc/ssh/sshd_config
                  - sed -i -e '/^#AuthorizedKeysFile/s/^.*$/AuthorizedKeysFile .ssh\/authorized_keys/' /etc/ssh/sshd_config
                  - sed -i '$a AllowUsers desixma' /etc/ssh/sshd_config
                  - sleep 5
                  - apt update -y
                  - apt install -y postgresql postgresql-contrib
                  - reboot
                CONSUL_EOF  
}

resource "hcloud_server_network" "internal_consul" {
  count=3
  network_id = data.terraform_remote_state.network.outputs.network_id
  server_id  = element(hcloud_server.consul.*.id, count.index)
  # this split is a temporary hack until Hetzner has "real" subnet objects and not just a shadow API. 
  # the subnet id is a combination of network id and subnet CIDR, e.g. "123456-10.0.2.0/24")
  ip = cidrhost(split("-", data.terraform_remote_state.network.outputs.private_subnet_id)[1], 10+count.index)
}

