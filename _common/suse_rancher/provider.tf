terraform {
  required_providers {
    helm = {
      source                = "hashicorp/helm" # https://registry.terraform.io/providers/hashicorp/helm/latest
      version               = "3.2.0"
    }
    local = {
      source                = "hashicorp/local" # https://registry.terraform.io/providers/hashicorp/local/latest
      version               = "2.9.0"
    }
    rancher2                = {
      source                = "rancher/rancher2" # https://registry.terraform.io/providers/rancher/rancher2/latest
      version               = "14.1.1"
      configuration_aliases = [
        rancher2.admin,
        rancher2.bootstrap
      ]
    }
    ssh = {
      source                = "loafoe/ssh" # https://registry.terraform.io/providers/loafoe/ssh/latest/docs/resources/resource
      version               = "2.7.0"
    }
  }
}
