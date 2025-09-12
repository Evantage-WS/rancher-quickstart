variable ENV_AWS_ACCESS_KEY {
  description = "Environment variable containing the AWS Access Key"
  type        = string
  default     = null
}

variable ENV_AWS_SECRET_ACCESS_KEY {
  description = "Environment variable containing the AWS Secret Access Key"
  type        = string
  default     = null
}

variable ENV_AWS_REGION {
  description = "Environment variable containing the AWS Region"
  type        = string
  default     = null
}

variable ENV_AWS_ZONE {
  description = "Environment variable containing the AWS Zone"
  type        = string
  default     = null
}

variable ENV_SSH_PUBLIC_KEY_FILE {
  description = "Environment variable containing the location of the public key file for ssh access"
  type        = string
  sensitive   = true
  default     = null
}

variable ENV_SSH_PRIVATE_KEY_FILE {
  description = "Environment variable containing the location of the private key file for ssh access"
  type        = string
  sensitive   = true
  default     = null
}

variable ENV_RANCHER_SERVER_ADMIN_PASSWORD {
  description = "Environment variable containing the password for Rancher"
  type        = string
  sensitive   = true
  default     = null
}

variable ENV_SUSE_SECURITY_ADMIN_PASSWORD {
  description = "Environment variable containing the password for SUSE Security"
  type        = string
  sensitive   = true
  default     = null
}
