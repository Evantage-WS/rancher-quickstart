# K3s cluster for Rancher

resource "ssh_resource" "echo_install_k3s" {
  host = var.node_public_ip
  commands    = [
    "echo curl https://get.k3s.io | INSTALL_K3S_EXEC=\"server --cluster-init --tls-san ${var.node_public_ip} --node-external-ip ${var.node_public_ip} --node-ip ${var.node_internal_ip}\" INSTALL_K3S_SKIP_SELINUX_RPM=true INSTALL_K3S_VERSION=${var.rancher_kubernetes_version} sh -"
  ]
  user        = var.node_username
  private_key = var.ssh_private_key
}


resource "ssh_resource" "install_k3s" {
  depends_on = [ ssh_resource.echo_install_k3s ]
  host = var.node_public_ip
  commands    = [
    "bash -c 'curl https://get.k3s.io | INSTALL_K3S_EXEC=\"server --cluster-init --tls-san ${var.node_public_ip} --node-external-ip ${var.node_public_ip} --node-ip ${var.node_internal_ip}\" INSTALL_K3S_SKIP_SELINUX_RPM=true INSTALL_K3S_VERSION=${var.rancher_kubernetes_version} sh -'"
  ]
  user        = var.node_username
  private_key = var.ssh_private_key
}
