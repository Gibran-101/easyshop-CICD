# Unique Azure resource identifier for the container registry
output "acr_id" {
  description = "The ID of the container registry"
  value       = azurerm_container_registry.acr.id
}
#This output used in CI/CD pipelines to know where to push container images.
output "acr_login_server" {
  description = "The login server URL for the container registry"
  value       = azurerm_container_registry.acr.login_server
}

# Admin username for simple authentication - used with admin password
# Only available when admin_enabled = true
output "admin_username" {
  description = "The admin username for the container registry"
  value       = azurerm_container_registry.acr.admin_username
}

# Admin password for registry authentication - highly sensitive
# Used for docker login and CI/CD pipeline authentication
output "admin_password" {
  description = "The admin password for the container registry"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}