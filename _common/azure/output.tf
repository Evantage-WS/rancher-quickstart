output "rancher_server_url" {
  value     = module.rancher.rancher_url
}

output "rancher_node_ip" {
  value     = azurerm_linux_virtual_machine.rancher_node.public_ip_address
}

output "downstream_node_ip" {
  value     = azurerm_linux_virtual_machine.downstream_node.public_ip_address
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
  content   = "ssh ${local.config.azure_node_username}@${azurerm_linux_virtual_machine.rancher_node.public_ip_address}"
  filename  = "${local.output_directory_for_config_files}/_rancher_node_ip.sh"
}

resource "local_file" "downstream_node_ip" {
  content   = "ssh ${local.config.azure_node_username}@${azurerm_linux_virtual_machine.downstream_node.public_ip_address}"
  filename  = "${local.output_directory_for_config_files}/_downstream_node_ip.sh"
}
