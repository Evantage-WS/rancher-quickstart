variable ENV_GCP_ACCESS_FILE {
  description = "Environment variable containing the GCP Access File"
  type        = string
  default     = null
}

variable ENV_GCP_LOGIN_NAME {
  description = "Environment variable containing the GCP Login Name"
  type        = string
  default     = null
}

variable ENV_GCP_PROJECT {
  description = "Environment variable containing the GCP Project"
  type        = string
  default     = null
}

variable ENV_GCP_REGION {
  description = "Environment variable containing the GCP Region"
  type        = string
  default     = null
}

variable ENV_GCP_ZONE {
  description = "Environment variable containing the GCP Zone"
  type        = string
  default     = null
}

variable ENV_SSH_PUBLIC_KEY_FILE {
  description = "Environment variable containing the location of the RSA public key file for ssh access"
  type        = string
  sensitive   = true
  default     = null
}

variable ENV_SSH_PRIVATE_KEY_FILE {
  description = "Environment variable containing the location of the RSA private key file for ssh access"
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