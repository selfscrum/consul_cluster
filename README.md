# consul_cluster

Create a Consul cluster with Hetzner Cloud

Parts of the scripts are coming from the fabulous [terraform-aws-consul](https://github.com/hashicorp/terraform-aws-consul) module, which I adopted for use in hcloud.

0. Fork the project and download to your disk.
1. Go to `tls/`,
2. Copy `variables.tf.original`to `variables.tf`. 
3. Add missing default values within `variables.tf` 
4. Run `terraform init`, `terraform plan`, `terraform apply` to create self-signed certificates. Alternatively, you can provide your own CA certificate `.ca.crt.pem`, private key `.consul.key.pem` and public key `.consul.crt.pem` into the packer directory.
5. Export your `HCLOUD_TOKEN` as environment variable
6. Go to `packer/`
7. Run `packer build consul.yaml`
8. Replace the `image` value in workspace\system.json with the id packer returned on completion.