# Terraform OpenVPN GCP
A terraform module to setup OpenVPN on GCP.


## Usage

```hcl
module "openvpn" {
  source     = "DeimosCloud/openvpn/google"
  version    = "~>2.1.1"
  name       = var.name
  region     = var.region
  project_id = var.project_id
  network    = module.vpc.network
  subnetwork = module.vpc.public_subnetwork
  output_dir = "${path.module}/openvpn"
  users      = ["bob", "alice"]
}

```

## Contributing

Report issues/questions/feature requests on in the issues section.

Full contributing guidelines are covered [here](CONTRIBUTING.md).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.41.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.2.3 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4.3 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.41.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.3 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_firewall.allow-external-ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow-openvpn-udp-port](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance_from_template.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_from_template) | resource |
| [google_compute_instance_template.tpl](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [local_sensitive_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [null_resource.openvpn_download_configurations](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.openvpn_update_users_script](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [tls_private_key.ssh-key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_delete_disk"></a> [auto\_delete\_disk](#input\_auto\_delete\_disk) | Whether or not the boot disk should be auto-deleted | `string` | `false` | no |
| <a name="input_create_ssh_fw_rule"></a> [create\_ssh\_fw\_rule](#input\_create\_ssh\_fw\_rule) | Indicates whether to create SSH Firewall rule | `bool` | `false` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | n/a | `string` | `"30"` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | (Optional) The GCE disk type. Can be either pd-ssd, local-ssd, pd-balanced or pd-standard | `string` | `"pd-standard"` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to be configured | `list(string)` | <pre>[<br>  "8.8.8.8",<br>  "8.8.4.4"<br>]</pre> | no |
| <a name="input_image_family"></a> [image\_family](#input\_image\_family) | n/a | `string` | `"ubuntu-2004-lts"` | no |
| <a name="input_install_script_url"></a> [install\_script\_url](#input\_install\_script\_url) | The commit sha we are using in order to determine which version of the install file to use: https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh | `string` | `"https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels, provided as a map | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type to create, e.g. n1-standard-1 | `string` | `"n1-standard-1"` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | Metadata, provided as a map | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | The name to use when generating resources | `string` | `""` | no |
| <a name="input_network"></a> [network](#input\_network) | The name or self\_link of the network to attach this interface to. Use network attribute for Legacy or Auto subnetted networks and subnetwork for custom subnetted networks. | `string` | `"default"` | no |
| <a name="input_network_project_id"></a> [network\_project\_id](#input\_network\_project\_id) | The GCP Host Project ID | `string` | `null` | no |
| <a name="input_network_tier"></a> [network\_tier](#input\_network\_tier) | Network network\_tier | `string` | `"PREMIUM"` | no |
| <a name="input_output_dir"></a> [output\_dir](#input\_output\_dir) | Folder to store all user openvpn details | `string` | `"openvpn"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP Project ID | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The GCP Project Region | `string` | `null` | no |
| <a name="input_remote_user"></a> [remote\_user](#input\_remote\_user) | The user to operate as on the VM. SSH Key is generated for this user | `string` | `"ubuntu"` | no |
| <a name="input_route_only_private_ips"></a> [route\_only\_private\_ips](#input\_route\_only\_private\_ips) | Routes only private IPs through the VPN (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) | `string` | `false` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account. | <pre>object({<br>    email  = string,<br>    scopes = set(string)<br>  })</pre> | <pre>{<br>  "email": null,<br>  "scopes": []<br>}</pre> | no |
| <a name="input_ssh_source_ranges"></a> [ssh\_source\_ranges](#input\_ssh\_source\_ranges) | SSH IP ranges allowed to ssh to openvpn server | `list(string)` | `[]` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | The name of the subnetwork to attach this interface to. The subnetwork must exist in the same region this instance will be created in. Either network or subnetwork must be provided. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | network tags to attach to the instance | `list(string)` | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | list of user to create | `list(string)` | `[]` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The GCP Zone to deploy VPN Compute instance to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | The created address |
| <a name="output_users"></a> [users](#output\_users) | Created Users |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
