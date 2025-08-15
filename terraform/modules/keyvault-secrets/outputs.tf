# Client ID of the managed identity for CSI Secret Store driver configuration
# Used in SecretProviderClass to authenticate with Key Vault
output "managed_identity_client_id" {
  description = "Client ID of the managed identity for Key Vault access"
  value       = azurerm_user_assigned_identity.keyvault_identity.client_id
  sensitive   = false
}

# Principal ID of the managed identity for role assignments and access policies
# Used internally for additional role assignments if needed
output "managed_identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.keyvault_identity.principal_id
  sensitive   = false
}

# Full resource ID of the managed identity for advanced configurations
# Used for complex role assignments or cross-subscription scenarios
output "managed_identity_id" {
  description = "Full resource ID of the managed identity"
  value       = azurerm_user_assigned_identity.keyvault_identity.id
  sensitive   = false
}

# List of all secrets created in Key Vault for documentation and verification
# Useful for confirming all expected secrets were created successfully
output "secrets_stored" {
  description = "List of secrets stored in Key Vault"
  value = [
    azurerm_key_vault_secret.mongodb_username.name,
    azurerm_key_vault_secret.mongodb_password.name,
    azurerm_key_vault_secret.mongodb_database.name,
    azurerm_key_vault_secret.mongodb_uri.name,
    azurerm_key_vault_secret.redis_password.name,
    azurerm_key_vault_secret.redis_uri.name
  ]
}