terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

provider "kubernetes" {
  host                   = yamldecode(base64decode(module.aks.kube_config))["clusters"][0]["cluster"]["server"]
  client_certificate     = base64decode(yamldecode(base64decode(module.aks.kube_config))["users"][0]["user"]["client-certificate-data"])
  client_key             = base64decode(yamldecode(base64decode(module.aks.kube_config))["users"][0]["user"]["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(base64decode(module.aks.kube_config))["clusters"][0]["cluster"]["certificate-authority-data"])

}
