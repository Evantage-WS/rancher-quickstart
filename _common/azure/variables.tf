variable azure_tenant {
  type        = string
  default     = null
}

variable azure_client_id {
  type        = string
  default     = null
}

variable azure_subscription_id {
  type        = string
  default     = null
}

variable azure_secret {
  type        = string
  default     = null
}

variable azure_location {
  type        = string
  default     = null
}

variable ssh_public_key_file {
  type        = string
  sensitive   = true
  default     = null
}

variable ssh_private_key_file {
  type        = string
  sensitive   = true
  default     = null
}

variable rancher_server_admin_password {
  type        = string
  sensitive   = true
  default     = null
}

variable suse_security_admin_password {
  type        = string
  sensitive   = true
  default     = null
}

variable config_file {
  type        = string
  sensitive   = true
  default     = null
}
