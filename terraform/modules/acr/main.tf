# Create the Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic" # Basic is enough for personal project
  admin_enabled       = true    # Enable admin user for simple authentication

  tags = var.tags
}