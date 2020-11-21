Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

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

    - sed -i -e '/^#DNS=/s/^.*$/DNS=213.133.100.100 213.133.99.99 213.133.98.98/' /etc/systemd/resolved.conf
#    - printf "network:\n    version: 2\n    ethernets:\n        enp7s0:\n            dhcp4: true\n            nameservers:\n                addresses: [9.9.9.9]\n            routes:\n                - to: 0.0.0.0/0\n                  via: 10.0.0.1\n                  on-link: true" > /etc/netplan/myplan.yaml
#    - rm -f /etc/netplan/50-cloud-init.yaml
#    - ip route add default via 10.0.0.1
    - chmod +x /opt/consul/bin/run-consul
    - sleep 5
    - apt update -y
    - apt install hcloud-cli
#    - reboot

cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash
# This script is meant to be run in the User Data of each Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in server mode. 
# Note that this script assumes it's running in an hcloud snapshot built from the Packer template in packer/consul.yaml.

set -e

# These variables are passed in via Terraform template interpolation
if [[ "${enable_gossip_encryption}" == "true" && ! -z "${gossip_encryption_key}" ]]; then
  # Note that setting the encryption key in plain text here means that it will be readable from the Terraform state file
  # and/or the console. We're doing this for simplicity, but in a real production environment you should pass an
  # encrypted key to Terraform and decrypt it before passing it to run-consul with something like KMS.
  gossip_encryption_configuration="--enable-gossip-encryption --gossip-encryption-key ${gossip_encryption_key}"
fi

if [[ "${enable_rpc_encryption}" == "true" && ! -z "${ca_path}" && ! -z "${cert_file_path}" && ! -z "${key_file_path}" ]]; then
  rpc_encryption_configuration="--enable-rpc-encryption --ca-path ${ca_path} --cert-file-path ${cert_file_path} --key-file-path ${key_file_path}"
fi

# as long as we don't have private network DNS, we need to hack into finding the leader...
#/opt/consul/bin/run-consul --server --cluster-tag-key "${cluster_tag_key}" --cluster-tag-value "${cluster_tag_value}" --environment HCLOUD_TOKEN=\""${hcloud_token}"\" $gossip_encryption_configuration $rpc_encryption_configuration

/opt/consul/bin/run-consul --server --cluster-tag-key "[ \"10.0.2.10\", \"10.0.2.11\", \"10.0.2.12\" ]" --cluster-tag-value "${cluster_tag_value}" --environment HCLOUD_TOKEN=\""${hcloud_token}"\" $gossip_encryption_configuration $rpc_encryption_configuration

--//
