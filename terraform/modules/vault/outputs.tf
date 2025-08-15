# Unique Azure resource identifier for the Key Vault
# Used by other modules for access policy assignments and secret creation
output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.this.id
}

# Key Vault name for CLI operations and application configuration
# Used in az keyvault commands and CSI Secret Store provider configurations
output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.this.name
}

# Key Vault URI for application SDKs and direct REST API access
# Format: https://keyvaultname.vault.azure.net/
output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.this.vault_uri
}

# Azure AD tenant ID for authentication configuration in applications
# Used by CSI drivers and application SDKs for proper authentication context
output "tenant_id" {
  description = "The tenant ID of the Key Vault"
  value       = azurerm_key_vault.this.tenant_id
}