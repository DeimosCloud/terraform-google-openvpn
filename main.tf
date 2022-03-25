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
  name              = var.name == "" ? "" : "${var.name}-"
  access_config = [{
    nat_ip       = google_compute_address.default.address
    network_tier = var.network_tier
  }]
}

resource "google_compute_firewall" "allow-external-ssh" {
  name    = "openvpn-${var.name}-allow-external-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = local.ssh_tag
}

resource "google_compute_address" "default" {
  name         = "openvpn-${var.name}-global-ip"
  region       = var.region
  network_tier = var.network_tier
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
}


// SSH Private Key
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh-key.private_key_pem
  filename        = "${var.output_dir}/${local.private_key_file}"
  file_permission = "0400"
}

resource "random_id" "this" {
  byte_length = "8"
}

resource "random_id" "password" {
  byte_length = "16"
}

// Use a persistent disk so that it can be remounted on another instance.
resource "google_compute_disk" "this" {
  name  = "openvpn-${var.name}-disk"
  image = var.image_family
  size  = var.disk_size_gb
  type  = var.disk_type
  zone  = var.zone
}

#-------------------
# Instance Template
#-------------------
resource "google_compute_instance_template" "tpl" {
  name_prefix  = "openvpn-${var.name}-"
  project      = var.project_id
  machine_type = var.machine_type
  labels       = var.labels
  metadata     = local.metadata
  region       = var.region

  metadata_startup_script = <<SCRIPT
    curl -O ${var.install_script_url}
    chmod +x openvpn-install.sh
    mv openvpn-install.sh /home/${var.remote_user}/
    chown ${var.remote_user} /home/${var.remote_user}/openvpn-install.sh
    export AUTO_INSTALL=y
    export PASS=1
    # Select Google DNS
    export DNS=9
    /home/${var.remote_user}/openvpn-install.sh
  SCRIPT

  disk {
    auto_delete = var.auto_delete_disk
    boot        = true
    source      = google_compute_disk.this.name
  }

  dynamic "service_account" {
    for_each = [var.service_account]

    content {
      email  = lookup(service_account.value, "email", null)
      scopes = lookup(service_account.value, "scopes", null)
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    dynamic "access_config" {
      for_each = local.access_config

      content {
        nat_ip       = access_config.value.nat_ip
        network_tier = access_config.value.network_tier
      }
    }
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = "true"
  }
}

resource "google_compute_instance_from_template" "this" {
  name    = "openvpn-${var.name}"
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
  source_instance_template = google_compute_instance_template.tpl.self_link
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

  depends_on = [google_compute_instance_from_template.this, local_sensitive_file.private_key]
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
