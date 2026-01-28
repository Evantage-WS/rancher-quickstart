terraform {
  required_providers {
    azurerm = {
      source        = "hashicorp/azurerm" # https://registry.terraform.io/providers/hashicorp/azurerm/latest
      version       = "4.58.0"
    }
    local = {
      source        = "hashicorp/local" # https://registry.terraform.io/providers/hashicorp/local/latest
      version       = "2.6.1"
    }
    helm = {
      source        = "hashicorp/helm" # https://registry.terraform.io/providers/hashicorp/helm/latest
      version       = "3.1.1"
    }
    rancher2 = {
      source        = "rancher/rancher2" # https://registry.terraform.io/providers/rancher/rancher2/latest
      version       = "13.1.4"
    }
    ssh = {
      source        = "loafoe/ssh" # https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource
      version       = "2.7.0"
    }
    null = {
      source        = "hashicorp/null" # https://registry.terraform.io/providers/hashicorp/null/latest
      version       = "3.2.4"
    }
  }
  required_version  = ">= 1.0.0"
}

provider "helm" {
  kubernetes = {
    config_path     = module.rancher.kubeconfig_file_rancher.filename
  }
}

provider "azurerm" {
  features {}

  subscription_id   = var.azure_subscription_id
  client_id         = var.azure_client_id
  client_secret     = var.azure_secret
  tenant_id         = var.azure_tenant
}

# Rancher2 bootstrapping provider
provider "rancher2" {
  alias             = "bootstrap"

  api_url           = module.rancher.rancher_url
  insecure          = true
  bootstrap         = true
}

# Rancher2 administration provider
provider "rancher2" {
  alias             = "admin"

  api_url           = module.rancher.rancher_url
  insecure          = true
  token_key         = module.rancher.rancher2_bootstrap_admin_token
  timeout           = "300s"
}
