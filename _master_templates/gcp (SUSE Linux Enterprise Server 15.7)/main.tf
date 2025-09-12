locals {
  #  home_directory = pathexpand(var.kubeconfig_location)

  # Read the config yaml file
  config_file = abspath("${path.module}/config.yaml")
  config      = yamldecode(file("${local.config_file}"))
}

module "cloud_gcp" {
  source                                  = "../../_common/gcp"

  config_file                             = local.config_file
  ssh_public_key_file                     = var.ENV_SSH_PUBLIC_KEY_FILE
  ssh_private_key_file                    = var.ENV_SSH_PRIVATE_KEY_FILE
  gcp_access_file                         = var.ENV_GCP_ACCESS_FILE
  gcp_project                             = var.ENV_GCP_PROJECT
  gcp_login_name                          = var.ENV_GCP_LOGIN_NAME
  gcp_region                              = var.ENV_GCP_REGION
  gcp_zone                                = var.ENV_GCP_ZONE
  rancher_server_admin_password           = var.ENV_RANCHER_SERVER_ADMIN_PASSWORD
  suse_security_admin_password            = var.ENV_SUSE_SECURITY_ADMIN_PASSWORD
}
