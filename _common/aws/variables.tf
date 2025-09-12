variable aws_access_key {
  type        = string
  default     = null
}

variable aws_secret_access_key {
  type        = string
  default     = null
}

variable aws_region {
  type        = string
  default     = null
}

variable aws_zone {
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

variable project_home {
  type        = string
  default     = null
}