# Simplified modules/keyvault-secrets/variables.tf

# Project name for consistent resource naming and organization
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Key Vault ID where secrets will be stored
variable "key_vault_id" {
  description = "ID of the Key Vault to store secrets in"
  type        = string
}

# Standard Azure tags for resource organization and cost tracking
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# REMOVED: All the identity and AKS-related variables
# - location
# - resource_group_name  
# - tenant_id
# - subscription_id
# - aks_kubelet_identity_object_id
# - aks_node_resource_group
# These are no longer needed since we're not creating custom identities
