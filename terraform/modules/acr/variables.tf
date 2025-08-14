# Name of the Azure Container Registry - must be globally unique across all Azure
variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.acr_name))
    error_message = "ACR name must be 5-50 characters, alphanumeric only, no hyphens or underscores."
  }
}

# Resource group where ACR will be created - must already exist
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# Azure region for ACR deployment - should match other resources for best performance
variable "location" {
  description = "Azure region for the ACR"
  type        = string
}

# Standard Azure tags for resource organization and cost tracking
variable "tags" {
  description = "Tags to apply to the ACR"
  type        = map(string)
  default     = {}
}