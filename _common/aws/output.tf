output "rancher_server_url" {
  value     = module.rancher.rancher_url
}

output "rancher_node_ip" {
  value     = aws_instance.rancher_node.public_ip
}

output "downstream_node_ip" {
  value     = aws_instance.downstream_node.public_ip
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
  content   = "ssh ${local.config.aws_node_username}@${aws_instance.rancher_node.public_ip}"
  filename  = "${local.output_directory_for_config_files}/_rancher_node_ip.sh"
}

resource "local_file" "downstream_node_ip" {
  content   = "ssh ${local.config.aws_node_username}@${aws_instance.downstream_node.public_ip}"
  filename  = "${local.output_directory_for_config_files}/_downstream_node_ip.sh"
}
