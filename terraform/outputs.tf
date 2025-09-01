# =======================
# Infrastructure Foundation Outputs
# =======================

# Resource group name where all resources are deployed
# Useful for manual operations and Azure CLI commands
output "resource_group_name" {
  description = "Resource group name"
  value       = module.networking.resource_group_name
}

# =======================
# Security and Secrets Management Outputs
# =======================

# Application Key Vault name for manual secret management
# Use with: az keyvault secret set --vault-name <this-value>
output "key_vault_name" {
  description = "Application Key Vault name"
  value       = module.app_keyvault.key_vault_name
}

# Key Vault URI for application SDK configuration
# Format: https://keyvaultname.vault.azure.net/
output "key_vault_uri" {
  description = "Application Key Vault URI"
  value       = module.app_keyvault.key_vault_uri
}

# =======================
# Network and DNS Outputs
# =======================

# Static IP address assigned to the ingress load balancer
# This is where your domain points and where traffic enters the cluster
output "static_ip_address" {
  description = "The static IP address"
  value       = azurerm_public_ip.ingress_ip.ip_address
}

# Azure-provided FQDN for the static IP (alternative to custom domain)
# Format: projectname-lb.eastus.cloudapp.azure.com
output "static_ip_fqdn" {
  description = "The Azure FQDN"
  value       = azurerm_public_ip.ingress_ip.fqdn
}

# DNS nameservers that must be configured at your domain registrar
# Critical: Update these at your domain provider for DNS to work
output "dns_nameservers" {
  description = "Nameservers to configure at your domain registrar"
  value       = module.dns.name_servers
}

# =======================
# Kubernetes Integration Outputs
# =======================

# Azure AD tenant ID for authentication configuration
# Required for CSI Secret Store driver and application authentication
output "tenant_id" {
  description = "Azure AD tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
  sensitive   = false
}

# List of all secrets stored in Key Vault for verification
# Helps confirm all expected application secrets were created
output "secrets_stored" {
  description = "List of secrets stored in Key Vault"
  value       = module.keyvault_secrets.secrets_stored
}

# =======================
# Container and Deployment Outputs
# =======================

# ACR login server URL for docker push/pull operations
# Used in CI/CD pipelines and local development
output "acr_login_server" {
  description = "ACR login server URL"
  value       = module.acr.acr_login_server
}

output "key_vault_addon_client_id" {
  description = "Client ID of the Key Vault CSI driver addon identity"
  value       = module.aks.key_vault_addon_identity.client_id
  sensitive   = false
}

output "key_vault_addon_object_id" {
  description = "Object ID of the Key Vault CSI driver addon identity"
  value       = module.aks.key_vault_addon_identity.object_id
  sensitive   = false
}

output "addon_identity_ready" {
  description = "Indicates if the addon identity is ready for use"
  value       = module.aks.addon_identity_ready
}