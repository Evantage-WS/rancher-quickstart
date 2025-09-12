# replace the 127.0.0.1 with the actual external ip address and the name default to the actual clustername in the kubeconfig for the rancher cluster
resource "ssh_resource" "change_kubeconfig_rancher_cluster" {
  depends_on = [
    ssh_resource.install_k3s
  ]
  host = var.node_public_ip
  commands = [
    "sudo sed -e \"s/127.0.0.1/${var.node_public_ip}/g\" -e \"s/: default/: k3s-${var.name_cloud_provider}-${var.kubernetes_cluster_name}-rancher/g\" /etc/rancher/k3s/k3s.yaml",
  ]
  user        = var.node_username
  private_key = var.ssh_private_key
}

# Save kubeconfig file of the Rancher cluster to the kubeconfig directory for use with lens, kubectl etc
resource "local_file" "kube_config_rancher_server_yaml_kubeconfig_dir" {
  filename = format("%s/%s", pathexpand("${var.kubeconfig_location}"), "k3s-${var.name_cloud_provider}-${var.kubernetes_cluster_name}-rancher.yaml")
  content  = ssh_resource.change_kubeconfig_rancher_cluster.result
}
