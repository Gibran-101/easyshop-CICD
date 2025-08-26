# Simplified modules/keyvault-secrets/outputs.tf

# List of all secrets created in Key Vault for documentation and verification
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

# REMOVED: All managed identity outputs
# - managed_identity_client_id
# - managed_identity_principal_id  
# - managed_identity_id
# These are no longer created by this module
