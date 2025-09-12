locals {
  # Read the config yaml file
  config_file                                           = var.config_file
  config                                                = yamldecode(file("${local.config_file}"))
  output_directory_for_config_files                     = "./__k8s/${local.config.name_cloud_provider}/${local.config.kubernetes_cluster_name}"
}
