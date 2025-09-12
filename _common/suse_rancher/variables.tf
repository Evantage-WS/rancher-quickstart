# Variables for rancher common module

# Required
variable "node_public_ip" {
  type        = string
  description = "Public IP of compute node for Rancher cluster"
}

variable "downstream_node_public_ip" {
  type        = string
  description = "Public IP of compute node for the downstream cluster"
}

variable "node_internal_ip" {
  type        = string
  description = "Internal IP of compute node for Rancher cluster"
}

# Required
variable "node_username" {
  type        = string
  description = "Username used for SSH access to the Rancher server cluster node"
}

# Required
variable "ssh_private_key" {
  type        = string
  description = "Private key used for SSH access to the Rancher server cluster node"
}

variable "rancher_kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for Rancher server cluster"
}

variable "cert_manager_version" {
  type        = string
  description = "Version of cert-manager to install alongside Rancher (format: 0.0.0)"
}

variable "rancher_version" {
  type        = string
  description = "Rancher server version (format v0.0.0)"
}

variable "rancher_server_dns" {
  type        = string
  description = "DNS host name of the Rancher server"
}

# Required
variable "admin_password" {
  type        = string
  description = "Admin password to use for Rancher server bootstrap, min. 12 characters"
}

variable "kubernetes_cluster_name" {
  type        = string
  description = "The name of the Kubernetes cluster where Rancher is installed on"
}

variable "downstream_kubernetes_cluster_version" {
  type        = string
  description = "Kubernetes version to use for managed downstream cluster"
}

variable "downstream_kubernetes_cluster_name" {
  type        = string
  description = "Name to use for managed downstream cluster"
}

variable "rancher_helm_repository" {
  type        = string
  description = "The helm repository, where the Rancher helm chart is installed from"
}

variable "kubeconfig_location" {
  type = string
  description = "Location to save the kubeconfig files"
}

variable "name_cloud_provider" {
  type = string
  description = "Name of the cloud provider, used in creating kubeconfig files"
}

