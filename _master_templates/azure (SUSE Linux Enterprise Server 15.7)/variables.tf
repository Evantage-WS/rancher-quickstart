variable ENV_AZURE_TENANT {
  description = "Environment variable containing the Azure Tenant"
  type        = string
  default     = null
}

variable ENV_AZURE_CLIENT_ID {
  description = "Environment variable containing the Azure Client ID"
  type        = string
  default     = null
}

variable ENV_AZURE_SUBSCRIPTION_ID {
  description = "Environment variable containing the Azure Subscription ID"
  type        = string
  default     = null
}

variable ENV_AZURE_SECRET {
  description = "Environment variable containing the Azure Secret"
  type        = string
  default     = null
}

variable ENV_AZURE_LOCATION {
  description = "Environment variable containing the Azure Location"
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
