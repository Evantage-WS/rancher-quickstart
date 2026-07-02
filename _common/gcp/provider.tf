terraform {
  required_providers {
    google = {
      source        = "hashicorp/google" # https://registry.terraform.io/providers/hashicorp/google/latest
      version       = "7.39.0"
    }
    local = {
      source        = "hashicorp/local" # https://registry.terraform.io/providers/hashicorp/local/latest
      version       = "2.9.0"
    }
    helm = {
      source        = "hashicorp/helm" # https://registry.terraform.io/providers/hashicorp/helm/latest
      version       = "3.2.0"
    }
    rancher2 = {
      source        = "rancher/rancher2" # https://registry.terraform.io/providers/rancher/rancher2/latest
      version       = "14.1.1"
    }
    ssh = {
      source        = "loafoe/ssh" # https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource
      version       = "2.7.0"
    }
    null = {
      source        = "hashicorp/null" # https://registry.terraform.io/providers/hashicorp/null/latest
      version       = "3.3.0"
    }
  }
  required_version  = ">= 1.0.0"
}

provider "helm" {
  kubernetes = {
    config_path     = module.rancher.kubeconfig_file_rancher.filename
  }
}

# gcloud auth application-default login
# gcloud auth application-default set-quota-project presales-emea-119943

provider "google" {
  credentials       = file(var.gcp_access_file)
  project           = var.gcp_project
  region            = var.gcp_region
  zone              = var.gcp_zone
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
