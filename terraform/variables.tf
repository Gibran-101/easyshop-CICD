# Global Variables
variable "resource_group_name" {}
variable "location" {}
variable "tags" {
  type = map(string)
}

# Networking
variable "vnet_name" {}

# ACR
variable "acr_name" {}

# AKS
variable "aks_cluster_name" {}

# DNS
variable "dns_zone_name" {}

# ArgoCD
variable "argocd_namespace" {}

# ArgoCD Image Updater
variable "github_repo_url" {}

# Observability
variable "observability_namespace" {}

# Vault
variable "vault_namespace" {}
