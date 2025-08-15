# Dedicated managed identity for Key Vault access from AKS
# Provides secure, passwordless authentication for CSI Secret Store driver
resource "azurerm_user_assigned_identity" "keyvault_identity" {
  name                = "${var.project_name}-keyvault-identity"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Generate secure random passwords for database and service authentication
# These passwords are cryptographically secure and managed by Terraform
resource "random_password" "mongodb_password" {
  length  = 32
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Generate random usernames to avoid conflicts and improve security
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

# Store individual MongoDB credentials in Key Vault for flexible access
resource "azurerm_key_vault_secret" "mongodb_username" {
  name         = "es-mongodb-username"
  value        = "mongouser${random_string.mongodb_username.result}"
  key_vault_id = var.key_vault_id

  tags = var.tags
}

resource "azurerm_key_vault_secret" "mongodb_password" {
  name         = "es-mongodb-password"
  value        = random_password.mongodb_password.result
  key_vault_id = var.key_vault_id

  tags = var.tags
}

resource "azurerm_key_vault_secret" "mongodb_database" {
  name         = "es-mongodb-database"
  value        = "easyshop"
  key_vault_id = var.key_vault_id

  tags = var.tags
}

# Complete MongoDB connection string for application use
# Assembles all connection components into ready-to-use format
resource "azurerm_key_vault_secret" "mongodb_uri" {
  name         = "es-mongodb-uri"
  value        = "mongodb://${azurerm_key_vault_secret.mongodb_username.value}:${azurerm_key_vault_secret.mongodb_password.value}@mongodb-0.mongodb-service.easyshop.svc.cluster.local:27017/easyshop?authSource=admin"
  key_vault_id = var.key_vault_id

  tags = var.tags

  depends_on = [
    azurerm_key_vault_secret.mongodb_username,
    azurerm_key_vault_secret.mongodb_password
  ]
}

# Store Redis credentials for caching and session management
resource "azurerm_key_vault_secret" "redis_password" {
  name         = "es-redis-password"
  value        = random_password.redis_password.result
  key_vault_id = var.key_vault_id

  tags = var.tags
}

# Redis connection string with authentication
resource "azurerm_key_vault_secret" "redis_uri" {
  name         = "es-redis-uri"
  value        = "redis://:${azurerm_key_vault_secret.redis_password.value}@easyshop-redis.easyshop.svc.cluster.local:6379"
  key_vault_id = var.key_vault_id

  tags = var.tags

  depends_on = [azurerm_key_vault_secret.redis_password]
}

# Grant the dedicated managed identity read access to Key Vault secrets
# Enables CSI Secret Store driver to mount secrets in AKS pods
resource "azurerm_key_vault_access_policy" "keyvault_identity_access" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.keyvault_identity.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# Allow AKS kubelet to use the managed identity for pod authentication
# Required for CSI driver to assume the identity and access Key Vault
resource "azurerm_role_assignment" "aks_identity_operator" {
  scope                = azurerm_user_assigned_identity.keyvault_identity.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.aks_kubelet_identity_object_id

  # Prevent Azure AD propagation issues
  skip_service_principal_aad_check = true
}

# Assign managed identity to AKS node resource group for VMSS access
# Enables identity to be used by pods running on AKS nodes
resource "azurerm_role_assignment" "aks_vmss_identity" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.aks_node_resource_group}"
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_user_assigned_identity.keyvault_identity.principal_id
}