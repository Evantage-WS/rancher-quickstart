terraform {
  required_providers {
    aws = {
      source        = "hashicorp/aws" # https://registry.terraform.io/providers/hashicorp/aws/latest
      version       = "6.13.0"
    }
    local = {
      source        = "hashicorp/local" # https://registry.terraform.io/providers/hashicorp/local/latest
      version       = "2.5.3"
    }
    helm = {
      source        = "hashicorp/helm" # https://registry.terraform.io/providers/hashicorp/helm/latest
      version       = "3.0.2"
    }
    rancher2 = {
      source        = "rancher/rancher2" # https://registry.terraform.io/providers/rancher/rancher2/latest
      version       = "8.1.0"
    }
    ssh = {
      source        = "loafoe/ssh" # https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource
      version       = "2.7.0"
    }
    null = {
      source = "hashicorp/null" # https://registry.terraform.io/providers/hashicorp/null/latest
      version = "3.2.4"
    }
  }
  required_version  = ">= 1.0.0"
}

provider "aws" {
  access_key        = var.aws_access_key
  secret_key        = var.aws_secret_access_key
  region            = var.aws_region
}

provider "helm" {
  kubernetes = {
    config_path     = module.rancher.kubeconfig_file_rancher.filename
  }
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
