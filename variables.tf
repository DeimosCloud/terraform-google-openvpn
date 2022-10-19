variable "project_id" {
  description = "The GCP Project ID"
  type        = string
  default     = null
}

variable "network_project_id" {
  description = "The GCP Host Project ID"
  type        = string
  default     = null
}

variable "name" {
  type        = string
  description = "The name to use when generating resources"
  default     = ""
}

variable "region" {
  description = "The GCP Project Region"
  type        = string
  default     = null
}

variable "zone" {
  description = "The GCP Zone to deploy VPN Compute instance to"
  type        = string
}

variable "network" {
  description = "The name or self_link of the network to attach this interface to. Use network attribute for Legacy or Auto subnetted networks and subnetwork for custom subnetted networks."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The name of the subnetwork to attach this interface to. The subnetwork must exist in the same region this instance will be created in. Either network or subnetwork must be provided."
  type        = string
  default     = null
}

variable "image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "disk_type" {
  description = "(Optional) The GCE disk type. Can be either pd-ssd, local-ssd, pd-balanced or pd-standard"
  type        = string
  default     = "pd-standard"
}

variable "disk_size_gb" {
  type    = string
  default = "30"
}

variable "auto_delete_disk" {
  description = "Whether or not the boot disk should be auto-deleted"
  type        = string
  default     = false
}

variable "service_account" {
  default = {
    email  = null
    scopes = []
  }
  type = object({
    email  = string,
    scopes = set(string)
  })
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account."
}

variable "metadata" {
  description = "Metadata, provided as a map"
  type        = map(string)
  default     = {}
}

variable "network_tier" {
  description = "Network network_tier"
  type        = string
  default     = "PREMIUM"
}

variable "labels" {
  default     = {}
  type        = map(string)
  description = "Labels, provided as a map"
}

variable "users" {
  default     = []
  type        = list(string)
  description = "list of user to create"
}

variable "tags" {
  description = "network tags to attach to the instance"
  type        = list(string)
  default     = []
}

variable "output_dir" {
  description = "Folder to store all user openvpn details"
  type        = string
  default     = "openvpn"
}

variable "remote_user" {
  description = "The user to operate as on the VM. SSH Key is generated for this user"
  type        = string
  default     = "ubuntu"
}

variable "machine_type" {
  description = "Machine type to create, e.g. n1-standard-1"
  type        = string
  default     = "n1-standard-1"
}

variable "route_only_private_ips" {
  description = "Routes only private IPs through the VPN (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)"
  type        = string
  default     = false
}

variable "install_script_url" {
  description = "The commit sha we are using in order to determine which version of the install file to use: https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh"
  type        = string
  default     = "https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh"
}

variable "dns_servers" {
  description = "The DNS servers to be configured"
  default     = ["8.8.8.8", "8.8.4.4"]
  type        = list(string)
  validation {
    condition     = length(var.dns_servers) >= 1 || length(var.dns_servers) <= 2
    error_message = "The variable 'var.dns_servers' should be an array with 1 or 2 DNS entries only."
  }
}

variable "create_ssh_fw_rule" {
  description = "Indicates whether to create SSH Firewall rule"
  type        = bool
  default     = false
}

variable "ssh_source_ranges" {
  description = "SSH IP ranges allowed to ssh to openvpn server"
  type        = list(string)
  default     = []
}
