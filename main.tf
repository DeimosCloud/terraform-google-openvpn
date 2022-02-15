# Uses https://github.com/angristan/openvpn-install to setup VPN in a google VM
# creates and deletes users accordingly

locals {
  metadata = merge(var.metadata, {
    sshKeys = "${var.remote_user}:${tls_private_key.ssh-key.public_key_openssh}"
  })
  ssh_tag          = ["allow-ssh"]
  tags             = toset(concat(var.tags, local.ssh_tag))
  output_folder    = var.output_dir
  private_key_file = "private-key.pem"
  # adding the null_resource to prevent evaluating this until the openvpn_update_users has executed
  refetch_user_ovpn = null_resource.openvpn_update_users_script.id != "" ? !alltrue([for x in var.users : fileexists("${var.output_dir}/${x}.ovpn")]) : false
  prefix            = var.prefix == "" ? "" : "${var.prefix}-"

}

resource "google_compute_firewall" "allow-external-ssh" {
  name    = "${local.prefix}openvpn-allow-external-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = local.ssh_tag
}

resource "google_compute_address" "default" {
  name         = "global-openvpn-ip"
  region       = var.region
  network_tier = var.network_tier
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
}


// SSH Private Key
resource "local_file" "private_key" {
  sensitive_content = tls_private_key.ssh-key.private_key_pem
  filename          = "${var.output_dir}/${local.private_key_file}"
  file_permission   = "0400"
}

resource "random_id" "this" {
  byte_length = "8"
}

resource "random_id" "password" {
  byte_length = "16"
}

module "instance_template" {
  source               = "terraform-google-modules/vm/google//modules/instance_template"
  version              = "~>7.0.0"
  region               = var.region
  name_prefix          = "${local.prefix}openvpn"
  project_id           = var.project_id
  network              = var.network
  subnetwork           = var.subnetwork
  metadata             = local.metadata
  machine_type         = var.machine_type
  service_account      = var.service_account
  source_image         = var.source_image
  source_image_project = var.source_image_project
  source_image_family  = var.source_image_family
  disk_size_gb         = var.disk_size_gb


  startup_script = <<SCRIPT
    curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
    chmod +x openvpn-install.sh
    mv openvpn-install.sh /home/${var.remote_user}/
    export AUTO_INSTALL=y
    export PASS=1
    # Select Google DNS
    export DNS=9
    /home/${var.remote_user}/openvpn-install.sh
  SCRIPT

  tags   = local.tags
  labels = var.labels
}


resource "google_compute_instance_from_template" "this" {
  name    = "${local.prefix}openvpn"
  project = var.project_id
  zone    = var.zone

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    access_config {
      nat_ip       = google_compute_address.default.address
      network_tier = var.network_tier
    }
  }

  source_instance_template = module.instance_template.self_link
}

resource "null_resource" "openvpn_install_script" {
    triggers = {
      policy_sha1 = sha1("https://raw.githubusercontent.com/angristan/openvpn-install/${var.openvpn_install_commit_sha}/openvpn-install.sh")
  }

  connection {
    type        = "ssh"
    user        = var.remote_user
    host        = google_compute_address.default.address
    private_key = tls_private_key.ssh-key.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.remote_user}/ && curl -O https://raw.githubusercontent.com/angristan/openvpn-install/${var.openvpn_install_commit_sha}/openvpn-install.sh",
      "chmod +x /home/${var.remote_user}/openvpn-install.sh"
    ]
    when = create
  }
}

# Updates/creates the users VPN credentials on the VPN server
resource "null_resource" "openvpn_update_users_script" {
  triggers = {
    users    = join(",", var.users)
    instance = google_compute_instance_from_template.this.instance_id
  }

  connection {
    type        = "ssh"
    user        = var.remote_user
    host        = google_compute_address.default.address
    private_key = tls_private_key.ssh-key.private_key_pem
  }

  provisioner "file" {
    source      = "${path.module}/scripts/update_users.sh"
    destination = "/home/${var.remote_user}/update_users.sh"
    when        = create
  }

  # Create New User with MENU_OPTION=1
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /etc/openvpn/server.conf ]; do sleep 10; done",
      "chmod +x ~${var.remote_user}/update_users.sh",
      "sudo ROUTE_ONLY_PRIVATE_IPS='${var.route_only_private_ips}' ~${var.remote_user}/update_users.sh ${join(" ", var.users)}",
    ]
    when = create
  }

  # Delete OVPN files if new instance is created
  provisioner "local-exec" {
    command = "rm -rf ${abspath(var.output_dir)}/*.ovpn"
    when    = create
  }

  depends_on = [google_compute_instance_from_template.this, local_file.private_key]
}


# Download user configurations to output_dir
resource "null_resource" "openvpn_download_configurations" {
  triggers = {
    trigger = timestamp()
  }

  depends_on = [null_resource.openvpn_update_users_script]

  # Copy .ovpn config for user from server to var.output_dir
  provisioner "local-exec" {
    working_dir = var.output_dir
    command     = "${abspath(path.module)}/scripts/refetch_user.sh"
    environment = {
      REFETCH_USER_OVPN = local.refetch_user_ovpn
      PRIVATE_KEY_FILE  = local.private_key_file
      REMOTE_USER       = var.remote_user
      IP_ADDRESS        = google_compute_address.default.address
    }
    when = create
  }
}
