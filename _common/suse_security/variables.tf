variable "suse_security_version" {
  type        = string
  description = "Version of SUSE Security to install alongside Rancher (format: 0.0.0)"
  default = null
}

variable "rancher_url" {
  type        = string
  description = "The url of the Kubernetes cluster where Rancher is installed on"
  default = null
}

variable "kubernetes_cluster_name" {
  type        = string
  description = "The name of the Rancher Kubernetes cluster"
  default = null
}

variable suse_security_admin_password {
  type        = string
  description = "Admin password for SUSE Security"
  sensitive   = true
  default     = null
}

variable "suse_security_server_dns" {
  type        = string
  description = "DNS host name of the SUSE Security server"
}

variable "ssh_username" {
  type        = string
  description = "SSH username"
}

variable "ssh_private_key" {
  type        = string
  description = "Private key used for SSH access to the Rancher server cluster node"
}

variable "rancher_node_public_ip" {
  type        = string
  description = "Public ip address of the Rancher Node"
}

