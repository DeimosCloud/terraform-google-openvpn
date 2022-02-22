variable "prefix" {
  description = "prefix to use for all resource"
  default     = ""
}
variable "project_id" {
  description = "The GCP Project ID"
  default     = null
}

variable "region" {
  description = "The GCP Project Region"
  default     = null
}

variable "zone" {
  description = "The GCP Zone to deploy VPN Compute instance to"
}

variable "network" {
  description = "The name or self_link of the network to attach this interface to. Use network attribute for Legacy or Auto subnetted networks and subnetwork for custom subnetted networks."
  default     = "default"
}

variable "subnetwork" {
  description = "The name of the subnetwork to attach this interface to. The subnetwork must exist in the same region this instance will be created in. Either network or subnetwork must be provided."
  default     = null
}

# variable "source_image_project" {
#   type    = string
#   default = "ubuntu-os-cloud"
# }

variable "image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}

# variable "source_image" {
#   description = "The source image for the image family. If not specified, terraform will try to create a new instance template anytime an update for an image familty is release"
#   type        = string
#   default     = "ubuntu-2004-focal-v20210415"
# }

variable "disk_type" {
  description = "(Optional) The GCE disk type. Can be either pd-ssd, local-ssd, pd-balanced or pd-standard"
  default     = "pd-standard"
}

variable "disk_size_gb" {
  type    = string
  default = "30"
}

variable "auto_delete_disk" {
  description = "Whether or not the boot disk should be auto-deleted"
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
  default     = {}
}

variable "network_tier" {
  description = "Network network_tier"
  default     = "STANDARD"
}

variable "labels" {
  default     = {}
  description = "Labels, provided as a map"
}

variable "users" {
  default     = []
  type        = list(string)
  description = "list of user to create"
}

variable "tags" {
  description = "network tags to attach to the instance"
  default     = []
}

variable "output_dir" {
  description = "Folder to store all user openvpn details"
  default     = "openvpn"
}

variable "remote_user" {
  description = "The user to operate as on the VM. SSH Key is generated for this user"
  default     = "ubuntu"
}

variable "machine_type" {
  description = "Machine type to create, e.g. n1-standard-1"
  default     = "n1-standard-1"
}

variable "route_only_private_ips" {
  description = "Routes only private IPs through the VPN (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)"
  default     = false
}

variable "attach_public_ip" {
  description = "Whether to make the instance public or not"
  default     = false
}

variable "install_script_commit_sha" {
  description = "The commit sha we are using in order to determine which version of the install file to use: https://raw.githubusercontent.com/angristan/openvpn-install/7d5c2d9/openvpn-install.sh"
  type        = string
  default     = "7d5c2d9"
}