# Azure Key Vault for secure storage of application secrets, keys, and certificates
# Provides centralized secret management with fine-grained access control and audit logging
resource "azurerm_key_vault" "this" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

 # Security configuration - controls what Azure services can use this vault for
  enabled_for_disk_encryption     = true  # VMs can get disk encryption keys
  enabled_for_template_deployment = true #VMs can get certificates during startup
  purge_protection_enabled        = true # Keep as true (can't be changed anyway)
  soft_delete_retention_days      = 90   # Keep original value

  # Access policy for the admin user/service principal - provides full control for management
  access_policy {
    tenant_id = var.tenant_id
    object_id = var.admin_object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge",
      "Recover",
      "Backup",
      "Restore"
    ]

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Purge",
      "Recover",
      "Backup",
      "Restore"
    ]

    certificate_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Purge",
      "Recover",
      "Backup",
      "Restore",
      "Import"
    ]
  }

  #Network access control - controls which networks can reach the vault
  # null = public access, configured object = restricted access
  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      ip_rules                   = lookup(network_acls.value, "ip_rules", [])
      virtual_network_subnet_ids = lookup(network_acls.value, "virtual_network_subnet_ids", [])
    }
  }

  tags = var.tags
}

# Optional: Add diagnostic settings for monitoring
# resource "azurerm_monitor_diagnostic_setting" "keyvault" {
#   count              = var.enable_diagnostics ? 1 : 0
#   name               = "${var.key_vault_name}-diagnostics"
#   target_resource_id = azurerm_key_vault.this.id

#   # Send logs to Log Analytics if workspace ID is provided
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   enabled_log {
#     category = "AuditEvent"
#   }

#   metric {
#     category = "AllMetrics"
#   }
# }