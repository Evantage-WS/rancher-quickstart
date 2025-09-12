output "rancher_url" {
  value       = "https://${var.rancher_server_dns}"
}

output "custom_cluster_command" {
  description = "Join command used to add a node to the cluster"
  value       = rancher2_cluster_v2.downstream.cluster_registration_token.0.insecure_node_command
}

output "kubeconfig_file_rancher" {
  description = "Kubeconfig file Rancher server"
  value       = local_file.kube_config_rancher_server_yaml_kubeconfig_dir
}

output "rancher2_bootstrap_admin_token" {
  description = "Token used for joining Rancher"
  value       = rancher2_bootstrap.admin.token
}
