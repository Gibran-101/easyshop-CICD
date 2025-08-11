variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.acr_name))
    error_message = "ACR name must be 5-50 characters, alphanumeric only, no hyphens or underscores."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the ACR"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the ACR"
  type        = map(string)
  default     = {}
}