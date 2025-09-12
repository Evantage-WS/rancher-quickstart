# Helm resources



# Install neuvector-crd helm chart
resource "helm_release" "neuvector-crd" {
  name              = "neuvector-crd"
  chart             = "crd"
  repository        = "https://neuvector.github.io/neuvector-helm/"
  namespace         = "cattle-neuvector-system"
  create_namespace  = true
  wait              = true
  force_update      = true

  # We need to wait for the Rancher web-hook external endpoint to have an ip address
  provisioner "remote-exec" {
    inline = [
      "until [[ $(sudo -E env \"PATH=$PATH;/usr/local/bin\" k3s kubectl get endpoints/rancher-webhook -n cattle-system -o=jsonpath='{.subsets[*].addresses[*].ip}') ]]; do sleep 5; done",
    ]

    connection {
      type                                = "ssh"
      host                                = var.rancher_node_public_ip
      user                                = var.ssh_username
      private_key                         = var.ssh_private_key
    }
  }

}

# Install neuvector-core helm chart
resource "helm_release" "neuvector-core" {
  depends_on = [ helm_release.neuvector-crd ]
  name              = "neuvector-core"
  chart             = "core"
  repository        = "https://neuvector.github.io/neuvector-helm/"
  namespace         = "cattle-neuvector-system"
  create_namespace  = true
  wait              = true
  force_update      = true

  values = [
    <<EOT
runtimePath: /run/k3s/containerd/containerd.sock
tag: ${var.suse_security_version}
crdwebhook:
  enabled: false
global:
  cattle:
    url: ${var.rancher_url}
controller:
  ranchersso:
    enabled: true
  secret:
    enabled: true
    data:
      sysinitcfg.yaml:
        Cluster_Name: ${var.kubernetes_cluster_name}
      userinitcfg.yaml:
        users:
          - Fullname: admin
            Username: admin
            Role: admin
            Password: ${var.suse_security_admin_password}
  ingress:
    enabled: false
  apisvc:
    type: ClusterIP
  replicas: 1
  pvc:
    enabled: true
    storageClass: local-path
    accessModes: ["ReadWriteOnce"]
cve:
  scanner:
    replicas: 1
manager:
  ingress:
    enabled: false
  svc:
    type: ClusterIP
EOT
  ]
}