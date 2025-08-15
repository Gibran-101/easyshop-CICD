# =======================
# Global Project Configuration
# =======================

# Primary project identifier used across all resources for consistent naming
variable "project_name" {
  description = "Name of the project"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

# Existing resource group name if using pre-created resource group
# Leave empty to create new resource group based on project_name
variable "resource_group_name" {
  description = "The resource group name (if using existing)"
  type        = string
  default     = ""
}

# Azure region where all resources will be deployed
# Choose region close to users for better performance and lower latency
variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "East US"
}

# Azure region where all resources will be deployed
# Choose region close to users for better performance and lower latency
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "EasyShop"
    ManagedBy = "Terraform"
  }
}

# =======================
# Container Registry Configuration
# =======================

# Globally unique name for Azure Container Registry
variable "acr_name" {
  description = "Azure Container Registry name (must be globally unique)"
  type        = string
}

# =======================
# Kubernetes Cluster Configuration
# =======================

# Name for the AKS cluster - should be descriptive and unique within resource group
variable "aks_cluster_name" {
  description = "AKS cluster name"
  type        = string
}

# Number of worker nodes in the AKS cluster
variable "aks_node_count" {
  description = "Number of AKS nodes"
  type        = number
  default     = 2
}

# Virtual machine size for AKS worker nodes
# Standard_B2s is cost-effective for development, use D-series for production
variable "aks_vm_size" {
  description = "Size of AKS node VMs"
  type        = string
  default     = "Standard_B2s" # Cheaper default
}

# Enable automatic scaling based on workload demands
# Helps optimize costs by scaling down during low usage periods
variable "aks_enable_auto_scaling" {
  description = "Enable AKS auto-scaling"
  type        = bool
  default     = true
}

# =======================
# DNS and Domain Configuration
# =======================

# Your domain name for which Azure DNS will provide hosting
# Must be a domain you own and can configure nameservers for
variable "dns_zone_name" {
  description = "Azure DNS zone name"
  type        = string
}

# =======================
# GitOps and CI/CD Configuration
# =======================

# Kubernetes namespace where ArgoCD will be installed
# Standard practice is "argocd" but can be customized for multi-tenant setups
variable "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

# GitHub repository URL for ArgoCD Image Updater integration
# Used for automatic image tag updates in Git manifests
variable "github_repo_url" {
  description = "GitHub repository URL for ArgoCD"
  type        = string
}

# =======================
# Security and Access Configuration
# =======================

# Azure AD Object ID of additional admin user for Key Vault access
# Leave empty to use current user only. Get with: az ad signed-in-user show --query objectId
variable "admin_object_id" {
  description = "Azure AD Object ID of additional admin user/service principal (optional)"
  type        = string
  default     = ""
}
