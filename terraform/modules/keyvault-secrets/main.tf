# Simplified modules/keyvault-secrets/main.tf
# This version removes the custom managed identity and lets AKS addon handle authentication

# Generate secure random passwords for database and service authentication
resource "random_password" "mongodb_password" {
  length  = 32
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "random_string" "mongodb_username" {
  length  = 12
  special = false
  upper   = false
  numeric = true
  lower   = true
}

resource "random_password" "redis_password" {
  length  = 24
  special = false # Redis passwords work better without special chars
  upper   = true
  lower   = true
  numeric = true
}

# Store individual MongoDB credentials in Key Vault
resource "azurerm_key_vault_secret" "mongodb_username" {
  name         = "es-mongodb-username"
  value        = "mongouser${random_string.mongodb_username.result}"
  key_vault_id = var.key_vault_id
  tags         = var.tags
}

resource "azurerm_key_vault_secret" "mongodb_password" {
  name         = "es-mongodb-password"
  value        = random_password.mongodb_password.result
  key_vault_id = var.key_vault_id
  tags         = var.tags
}

resource "azurerm_key_vault_secret" "mongodb_database" {
  name         = "es-mongodb-database"
  value        = "easyshop"
  key_vault_id = var.key_vault_id
  tags         = var.tags
}

# Complete MongoDB connection string for application use
resource "azurerm_key_vault_secret" "mongodb_uri" {
  name         = "es-mongodb-uri"
  value        = "mongodb://${azurerm_key_vault_secret.mongodb_username.value}:${azurerm_key_vault_secret.mongodb_password.value}@mongodb-0.mongodb-service.easyshop.svc.cluster.local:27017/easyshop?authSource=admin"
  key_vault_id = var.key_vault_id
  tags         = var.tags

  depends_on = [
    azurerm_key_vault_secret.mongodb_username,
    azurerm_key_vault_secret.mongodb_password
  ]
}

# Store Redis credentials
resource "azurerm_key_vault_secret" "redis_password" {
  name         = "es-redis-password"
  value        = random_password.redis_password.result
  key_vault_id = var.key_vault_id
  tags         = var.tags
}

resource "azurerm_key_vault_secret" "redis_uri" {
  name         = "es-redis-uri"
  value        = "redis://:${azurerm_key_vault_secret.redis_password.value}@easyshop-redis.easyshop.svc.cluster.local:6379"
  key_vault_id = var.key_vault_id
  tags         = var.tags

  depends_on = [azurerm_key_vault_secret.redis_password]
}

# REMOVED: All the managed identity creation and role assignment code
# The AKS addon will handle authentication automatically
