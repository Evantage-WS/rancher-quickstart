# Rancher resources

# Initialize Rancher server
resource "rancher2_bootstrap" "admin" {
  depends_on = [
    helm_release.rancher_server
  ]

  provider            = rancher2.bootstrap

  password            = var.admin_password
}

# Create custom managed cluster
resource "rancher2_cluster_v2" "downstream" {
  provider            = rancher2.admin

  name                = var.downstream_kubernetes_cluster_name
  kubernetes_version  = var.downstream_kubernetes_cluster_version
}
