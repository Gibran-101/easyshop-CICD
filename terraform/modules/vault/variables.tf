# Name of the Key Vault - must be globally unique across all Azure
variable "key_vault_name" {
  description = "Name of the Key Vault (must be globally unique)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.key_vault_name))
    error_message = "Key Vault name must be 3-24 characters, contain only alphanumeric characters and hyphens."
  }
}

# Azure region for Key Vault deployment - should match other resources for best performance
variable "location" {
  description = "Azure region for the Key Vault"
  type        = string
}

# Resource group where Key Vault will be created - must already exist
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# Azure AD tenant ID for authentication and access control
# Get with: az account show --query tenantId -o tsv
variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

# Object ID of the admin user/service principal for initial Key Vault access
# Get with: az ad signed-in-user show --query objectId -o tsv
variable "admin_object_id" {
  description = "Object ID of the admin user/service principal"
  type        = string
}

# Network access control configuration - null means allow public access
# Configure to restrict access to specific IPs or VNets for enhanced security
variable "network_acls" {
  description = "Network ACLs for Key Vault (optional)"
  type = object({
    default_action             = string
    bypass                     = string
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = {
    default_action             = "Allow"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}

# Standard Azure tags for resource organization, cost tracking, and governance
variable "tags" {
  description = "Tags to apply to the Key Vault"
  type        = map(string)
  default     = {}
}