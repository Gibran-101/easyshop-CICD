# Global Variables
variable "project_name" {
  description = "Name of the project"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The resource group name (if using existing)"
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "EasyShop"
    ManagedBy = "Terraform"
  }
}

# ACR Variables
variable "acr_name" {
  description = "Azure Container Registry name (must be globally unique)"
  type        = string
}

# AKS Variables
variable "aks_cluster_name" {
  description = "AKS cluster name"
  type        = string
}

# DNS Variables
variable "dns_zone_name" {
  description = "Azure DNS zone name"
  type        = string
}

# ArgoCD Variables
variable "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "github_repo_url" {
  description = "GitHub repository URL for ArgoCD"
  type        = string
}

# Observability Variables
variable "observability_namespace" {
  description = "Kubernetes namespace for observability stack"
  type        = string
  default     = "monitoring"
}

# Vault Variables
variable "admin_object_id" {
  description = "Azure AD Object ID of additional admin user/service principal (optional)"
  type        = string
  default     = ""
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access Key Vault (optional)"
  type        = list(string)
  default     = []
}