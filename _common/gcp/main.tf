# Create _destroy.sh script, after the creation of the resourcegroup
# All created files at create time will be destroyed, except the files created by terraform init
resource "null_resource" "create_destroy_script" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    when = create
    working_dir = path.root
    command = <<EOT
    OUTPUT_FILE='_destroy.sh'
    echo '#!/usr/bin/env bash\n' > $${OUTPUT_FILE}

    echo 'echo "Remove firewall rule ${google_compute_firewall.firewall_rules_inbound.name}"' >> $${OUTPUT_FILE}
    echo 'gcloud --quiet --account=${var.gcp_login_name} --project=${var.gcp_project} compute firewall-rules delete ${google_compute_firewall.firewall_rules_inbound.name}' >> $${OUTPUT_FILE}

    echo 'echo "Remove firewall rule ${google_compute_firewall.firewall_rules_outbound.name}"' >> $${OUTPUT_FILE}
    echo 'gcloud --quiet --account=${var.gcp_login_name} --project=${var.gcp_project} compute firewall-rules delete ${google_compute_firewall.firewall_rules_outbound.name}' >> $${OUTPUT_FILE}

    echo 'echo "Remove vm ${google_compute_instance.downstream_node.name}"' >> $${OUTPUT_FILE}
    echo 'gcloud --quiet --account=${var.gcp_login_name} --project=${var.gcp_project} compute instances delete ${google_compute_instance.downstream_node.name} --zone=${var.gcp_region}-${var.gcp_zone}' >> $${OUTPUT_FILE}

    echo 'echo "Remove vm ${google_compute_instance.rancher_node.name}"' >> $${OUTPUT_FILE}
    echo 'gcloud --quiet --account=${var.gcp_login_name} --project=${var.gcp_project} compute instances delete ${google_compute_instance.rancher_node.name} --zone=${var.gcp_region}-${var.gcp_zone}' >> $${OUTPUT_FILE}

    echo 'echo "Remove vpc ${google_compute_network.vpc.name}"' >> $${OUTPUT_FILE}
    echo 'gcloud --quiet --account=${var.gcp_login_name} --project=${var.gcp_project} compute networks delete ${google_compute_network.vpc.name}' >> $${OUTPUT_FILE}

    echo 'echo "Remove ip address ${google_compute_address.downstream_node_public_ip.name}"' >> $${OUTPUT_FILE}
    echo 'gcloud --quiet --account=${var.gcp_login_name} --project=${var.gcp_project} compute addresses delete ${google_compute_address.downstream_node_public_ip.name} --region=${var.gcp_region}' >> $${OUTPUT_FILE}

    echo 'echo "Remove ip address ${google_compute_address.rancher_node_public_ip.name}"' >> $${OUTPUT_FILE}
    echo 'gcloud --quiet --account=${var.gcp_login_name} --project=${var.gcp_project} compute addresses delete ${google_compute_address.rancher_node_public_ip.name} --region=${var.gcp_region}' >> $${OUTPUT_FILE}

    echo 'echo "Remove local files"' >> $${OUTPUT_FILE}
    echo 'rm -rf terraform.tfstat*' >> $${OUTPUT_FILE}
    echo 'rm -rf '${local.config.kubeconfig_location}/k3s-${local.config.name_cloud_provider}-${local.config.kubernetes_cluster_name}-rancher.yaml'' >> $${OUTPUT_FILE}
    echo 'rm -rf '${local.config.kubeconfig_location}/k3s-${local.config.name_cloud_provider}-${local.config.kubernetes_cluster_name}-${local.config.downstream_kubernetes_cluster_name}.yaml'' >> $${OUTPUT_FILE}
    echo 'rm -rf ${local.output_directory_for_config_files}' >> $${OUTPUT_FILE}
    echo 'rm _destroy.sh' >> $${OUTPUT_FILE}
    chmod +x $${OUTPUT_FILE}
EOT
  }
}

# GCP Public Compute Address for rancher server node
resource "google_compute_address" "rancher_node_public_ip" {
  name                                    = "${local.config.gcp_prefix}-${local.config.kubernetes_cluster_name}-rancher-node-ipv4-address"
  labels = {
    creator                               = lower(replace(local.config.gcp_creator_tag," ","_"))
  }
}

# GCP Public Compute Address for quickstart node
resource "google_compute_address" "downstream_node_public_ip" {
  name                                    = "${local.config.gcp_prefix}-${local.config.kubernetes_cluster_name}-downstream-node-ipv4-address"
  labels = {
    creator                               = lower(replace(local.config.gcp_creator_tag," ","_"))
  }
}

# GCP VPC
resource "google_compute_network" "vpc" {
  name                                    = "${local.config.gcp_prefix}-${local.config.kubernetes_cluster_name}"
  auto_create_subnetworks                 = true
  routing_mode                            = "GLOBAL"
  description                             = "${local.config.gcp_creator_tag} Demo"
}

# Firewall Rule to allow all traffic
resource "google_compute_firewall" "firewall_rules_inbound" {
  name                                    = "${local.config.gcp_prefix}-${local.config.kubernetes_cluster_name}-firewall-rules-inbound"
  direction                               = "INGRESS"
  network                                 = google_compute_network.vpc.name

  allow {
    protocol                              = "icmp"
  }

  allow {
    protocol                              = "tcp"
    ports                                 = ["22", "6443", "80", "443"]
  }
  source_ranges                           = ["0.0.0.0/0"]
}

# Firewall Rule to allow all traffic
resource "google_compute_firewall" "firewall_rules_outbound" {
  name                                    = "${local.config.gcp_prefix}-${local.config.kubernetes_cluster_name}-firewall-rules-outbound"
  direction                               = "EGRESS"
  network                                 = google_compute_network.vpc.name

  allow {
    protocol                              = "all"
  }
  source_ranges                           = ["0.0.0.0/0"]
}

# GCP Compute Instance for creating a single node RKE cluster and installing the Rancher server
resource "google_compute_instance" "rancher_node" {
  depends_on = [
    google_compute_firewall.firewall_rules_inbound,
    google_compute_firewall.firewall_rules_outbound,
  ]

  name                                    = "${local.config.gcp_prefix}-${local.config.kubernetes_cluster_name}-rancher-node"
  machine_type                            = local.config.gcp_instance_type_rancher
  zone                                    = join("", [var.gcp_region, "-", var.gcp_zone])

  boot_disk {
    initialize_params {
      image                               = data.google_compute_image.sles.self_link
      size                                = 20
    }
  }

  network_interface {
    network                               = google_compute_network.vpc.name
    access_config {
      nat_ip                              = google_compute_address.rancher_node_public_ip.address
    }
  }

  labels = {
    creator                               = lower(replace(local.config.gcp_creator_tag," ","_"))
  }

  # See https://stackoverflow.com/questions/56389912/adding-a-ssh-key-to-an-gcp-instance-using-terraform-works-but-shows-error-on-the
  # We do need the username in the key as well and remove a return, if present
  metadata = {
    ssh-keys                              = "${local.config.gcp_node_username}:${replace(file(var.ssh_public_key_file), "\n", "")} ${local.config.gcp_node_username}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'SSH connection worked'",
    ]

    connection {
      type                                = "ssh"
      host                                = self.network_interface.0.access_config.0.nat_ip
      user                                = local.config.gcp_node_username
      private_key                         = file(var.ssh_private_key_file)
    }
  }
}

# Rancher resources
module "rancher" {
  source                                  = "../suse_rancher"

  providers = {
    helm                                  = helm
    rancher2.bootstrap                    = rancher2.bootstrap
    rancher2.admin                        = rancher2.admin
  }

  node_public_ip                          = google_compute_instance.rancher_node.network_interface.0.access_config.0.nat_ip
  node_internal_ip                        = google_compute_instance.rancher_node.network_interface.0.network_ip
  node_username                           = local.config.gcp_node_username
  downstream_node_public_ip               = google_compute_address.downstream_node_public_ip.address
  ssh_private_key                         = file(var.ssh_private_key_file)
  rancher_kubernetes_version              = local.config.rancher_kubernetes_version

  cert_manager_version                    = local.config.cert_manager_version
  rancher_version                         = local.config.rancher_version
  rancher_helm_repository                 = local.config.rancher_helm_repository

  rancher_server_dns                      = join(".", ["rancher", google_compute_instance.rancher_node.network_interface.0.access_config.0.nat_ip, "sslip.io"])

  admin_password                          = var.rancher_server_admin_password

  kubernetes_cluster_name                 = local.config.kubernetes_cluster_name
  downstream_kubernetes_cluster_version   = local.config.downstream_kubernetes_cluster_version
  downstream_kubernetes_cluster_name      = local.config.downstream_kubernetes_cluster_name
  kubeconfig_location                     = local.config.kubeconfig_location
  name_cloud_provider                     = local.config.name_cloud_provider
}

# GCP compute instance for creating a single node workload cluster
resource "google_compute_instance" "downstream_node" {
  depends_on = [
    google_compute_firewall.firewall_rules_inbound,
    google_compute_firewall.firewall_rules_outbound,
  ]

  name                                    = "${local.config.gcp_prefix}-${local.config.kubernetes_cluster_name}-${local.config.downstream_kubernetes_cluster_name}-node"
  machine_type                            = local.config.gcp_instance_type_downstream
  zone                                    = join("", [var.gcp_region, "-", var.gcp_zone])

  boot_disk {
    initialize_params {
      image                               = data.google_compute_image.sles.self_link
    }
  }

  network_interface {
    network                               = google_compute_network.vpc.name
    access_config {
      nat_ip                              = google_compute_address.downstream_node_public_ip.address
    }
  }

  labels = {
    creator                               = lower(replace(local.config.gcp_creator_tag," ","_"))
  }

  # See https://stackoverflow.com/questions/56389912/adding-a-ssh-key-to-an-gcp-instance-using-terraform-works-but-shows-error-on-the
  # We do need the username in the key as well and remove a return, if present
  metadata = {
    ssh-keys                              = "${local.config.gcp_node_username}:${replace(file(var.ssh_public_key_file), "\n", "")} ${local.config.gcp_node_username}"
  }

  metadata_startup_script = templatefile(
    "${path.module}/files/userdata_downstream_node.template",
    {
      register_command                    = module.rancher.custom_cluster_command
      public_ip                           = google_compute_address.downstream_node_public_ip.address
    }
  )

  provisioner "remote-exec" {
    inline = [
      "echo 'SSH connection worked'",
    ]

    connection {
      type                                = "ssh"
      host                                = self.network_interface.0.access_config.0.nat_ip
      user                                = local.config.gcp_node_username
      private_key                         = file(var.ssh_private_key_file)
    }
  }
}

# Install SUSE Security
module "suse_security" {
  depends_on = [
    google_compute_instance.downstream_node,
  ]

  count                                   = local.config.install_suse_security ? 1 : 0

  source                                  = "../suse_security"

  providers = {
    helm                                  = helm
  }
  suse_security_version                   = local.config.suse_security_version
  rancher_url                             = module.rancher.rancher_url
  kubernetes_cluster_name                 = local.config.kubernetes_cluster_name
  suse_security_admin_password            = var.suse_security_admin_password
  suse_security_server_dns                = join(".", ["suse_security", google_compute_instance.rancher_node.network_interface.0.access_config.0.nat_ip, "sslip.io"])
  ssh_username                            = local.config.gcp_node_username
  ssh_private_key                         = file(var.ssh_private_key_file)
  rancher_node_public_ip                  = google_compute_instance.rancher_node.network_interface.0.access_config.0.nat_ip
}
