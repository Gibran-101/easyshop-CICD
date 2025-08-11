provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  # Azure credentials come from environment variables (ARM_*)
  # set by GitHub Actions
}

# Kubernetes provider - configured after AKS is created
provider "kubernetes" {
  host                   = try(module.aks.kube_config[0].host, "")
  client_certificate     = try(base64decode(module.aks.kube_config[0].client_certificate), "")
  client_key             = try(base64decode(module.aks.kube_config[0].client_key), "")
  cluster_ca_certificate = try(base64decode(module.aks.kube_config[0].cluster_ca_certificate), "")
}

provider "helm" {
  kubernetes {
    host                   = try(module.aks.kube_config[0].host, "")
    client_certificate     = try(base64decode(module.aks.kube_config[0].client_certificate), "")
    client_key             = try(base64decode(module.aks.kube_config[0].client_key), "")
    cluster_ca_certificate = try(base64decode(module.aks.kube_config[0].cluster_ca_certificate), "")
  }
}