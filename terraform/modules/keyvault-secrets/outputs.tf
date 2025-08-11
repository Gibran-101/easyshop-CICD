# terraform/modules/keyvault-secrets/outputs.tf

output "managed_identity_client_id" {
  description = "Client ID of the managed identity for Key Vault access"
  value       = azurerm_user_assigned_identity.keyvault_identity.client_id
  sensitive   = false
}

output "managed_identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.keyvault_identity.principal_id
  sensitive   = false
}

output "managed_identity_id" {
  description = "Full resource ID of the managed identity"
  value       = azurerm_user_assigned_identity.keyvault_identity.id
  sensitive   = false
}

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