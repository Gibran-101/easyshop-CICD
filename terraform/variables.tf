# Global Variables
variable "resource_group_name" {
  description = "The resource group name"
  type        = string
}
variable "location" {
  description = "Azure region to deploy resources."
  type        = string
}
variable "tags" {
  type = map(string)
}

# Networking
variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "vnet_name" {
  description = "Name of the VNet"
  type        = string
}

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
variable "admin_object_id" {
  type        = string
  description = "Azure AD Object ID of the admin user/service principal that needs access to Key Vault"
}

variable "client_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
}
