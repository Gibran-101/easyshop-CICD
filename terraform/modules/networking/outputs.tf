# Resource group name - used by other modules to place their resources
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

# Resource group ID - required for some Azure role assignments and policies
output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.rg.id
}

# Location passthrough - ensures other modules use the same region
output "location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.rg.location
}

# Virtual network name - needed if creating additional subnets outside this module
output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

# Virtual network ID - required for VNet peering or advanced networking configurations
output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

# AKS subnet ID - critical for AKS cluster deployment and node placement
output "aks_subnet_id" {
  description = "The ID of the AKS subnet"
  value       = azurerm_subnet.aks_subnet.id
}

# 🆕 Application Gateway subnet ID - required for App Gateway deployment
output "app_gateway_subnet_id" {
  description = "The ID of the Application Gateway subnet"
  value       = azurerm_subnet.app_gateway_subnet.id
}

# NSG ID - useful for adding additional security rules or associations
output "aks_nsg_id" {
  description = "The ID of the AKS Network Security Group"
  value       = azurerm_network_security_group.aks_nsg.id
}

# 🆕 Application Gateway NSG ID
output "app_gateway_nsg_id" {
  description = "The ID of the Application Gateway Network Security Group"
  value       = azurerm_network_security_group.app_gateway_nsg.id
}