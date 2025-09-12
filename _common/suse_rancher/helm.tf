# Helm resources

# Install cert-manager helm chart
resource "helm_release" "cert_manager" {
  name              = "cert-manager"
  chart             = "https://charts.jetstack.io/charts/cert-manager-v${var.cert_manager_version}.tgz"
  namespace         = "cert-manager"
  create_namespace  = true
  wait              = true
  values = [
    <<EOT
installCRDs: true
extraArgs: [--enable-certificate-owner-ref=true,--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=8.8.8.8:53,1.1.1.1:53]
    EOT
  ]
}

# Install Rancher helm chart
resource "helm_release" "rancher_server" {
  depends_on        = [
    helm_release.cert_manager,
  ]

  name              = "rancher"
  chart             = "${var.rancher_helm_repository}/rancher-${var.rancher_version}.tgz"
  namespace         = "cattle-system"
  create_namespace  = true
  wait              = true
  force_update      = true

  values = [
    <<EOT
hostname: ${var.rancher_server_dns}
replicas: 1
bootstrapPassword: admin
    EOT
  ]
}

