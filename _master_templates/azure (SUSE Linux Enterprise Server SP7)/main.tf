locals {
  #  home_directory = pathexpand(var.kubeconfig_location)

  # Read the config yaml file
  config_file = abspath("${path.module}/config.yaml")
  config      = yamldecode(file("${local.config_file}"))
}

module "cloud_azure" {
  source                                  = "../../_common/azure"

  # Azure gave me a problem with ED25519
  config_file                             = local.config_file
  ssh_public_key_file                     = var.ENV_SSH_PUBLIC_KEY_FILE
  ssh_private_key_file                    = var.ENV_SSH_PRIVATE_KEY_FILE
  azure_subscription_id                   = var.ENV_AZURE_SUBSCRIPTION_ID
  azure_client_id                         = var.ENV_AZURE_CLIENT_ID
  azure_secret                            = var.ENV_AZURE_SECRET
  azure_tenant                            = var.ENV_AZURE_TENANT
  azure_location                          = var.ENV_AZURE_LOCATION
  rancher_server_admin_password           = var.ENV_RANCHER_SERVER_ADMIN_PASSWORD
  suse_security_admin_password            = var.ENV_SUSE_SECURITY_ADMIN_PASSWORD
}
