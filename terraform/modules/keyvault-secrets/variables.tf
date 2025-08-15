# Project name for consistent resource naming and organization
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Azure region where managed identity will be created
variable "location" {
  description = "Azure region"
  type        = string
}

# Resource group for managed identity placement
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# Key Vault ID where secrets will be stored
variable "key_vault_id" {
  description = "ID of the Key Vault to store secrets in"
  type        = string
}

# Azure AD tenant ID for authentication context
variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

# Azure subscription ID for role assignment scoping
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

# AKS kubelet managed identity object ID for role assignments
variable "aks_kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet managed identity"
  type        = string
}

# AKS node resource group name for VMSS role assignments
variable "aks_node_resource_group" {
  description = "AKS node resource group name"
  type        = string
}

# Standard Azure tags for resource organization and cost tracking
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}