locals {
  #  home_directory = pathexpand(var.kubeconfig_location)

  # Read the config yaml file
  config_file = abspath("${path.module}/config.yaml")
  config      = yamldecode(file("${local.config_file}"))
}

module "cloud_aws" {
  source                                  = "../../_common/aws"

  config_file                             = local.config_file
  ssh_public_key_file                     = var.ENV_SSH_PUBLIC_KEY_FILE
  ssh_private_key_file                    = var.ENV_SSH_PRIVATE_KEY_FILE
  aws_region                              = var.ENV_AWS_REGION
  aws_zone                                = var.ENV_AWS_ZONE
  aws_access_key                          = var.ENV_AWS_ACCESS_KEY
  aws_secret_access_key                   = var.ENV_AWS_SECRET_ACCESS_KEY
  rancher_server_admin_password           = var.ENV_RANCHER_SERVER_ADMIN_PASSWORD
  suse_security_admin_password            = var.ENV_SUSE_SECURITY_ADMIN_PASSWORD
}
