# consul_cluster

Create a Consul cluster with Hetzner Cloud

Parts of the scripts are coming from the fabulous [terraform-aws-consul](https://github.com/hashicorp/terraform-aws-consul) project, which I adopted for use in hcloud.

1. Go to `tls/`,
2. Copy `variables.tf.original`to `variables.tf`. 
3. Add missing default values within `variables.tf` 
4. Run `terraform init`, `terraform plan`, `terraform apply`
5. Export your `HCLOUD_TOKEN` as environment variable
6. Go to `packer\`
6. Run `packer build consul.yaml`