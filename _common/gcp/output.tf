output "rancher_server_url" {
  value     = module.rancher.rancher_url
}

output "rancher_node_ip" {
  value     = google_compute_instance.rancher_node.network_interface.0.access_config.0.nat_ip
}

output "downstream_node_ip" {
  value     = google_compute_instance.downstream_node.network_interface.0.access_config.0.nat_ip
}

resource "local_file" "rancher_url_to_file" {
  content   = templatefile("${path.module}/files/url.template",
    {
      url   = module.rancher.rancher_url
    }
  )
  filename  = "${local.output_directory_for_config_files}/_rancher.url"
}

resource "local_file" "rancher_node_ip" {
  content   = "ssh ${local.config.gcp_node_username}@${google_compute_instance.rancher_node.network_interface.0.access_config.0.nat_ip}"
  filename  = "${local.output_directory_for_config_files}/_rancher_node_ip.sh"
}

resource "local_file" "downstream_node_ip" {
  content   = "ssh ${local.config.gcp_node_username}@${google_compute_instance.downstream_node.network_interface.0.access_config.0.nat_ip}"
  filename  = "${local.output_directory_for_config_files}/_downstream_node_ip.sh"
}
