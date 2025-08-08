output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.rg.id
}

output "location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.rg.location
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "aks_subnet_id" {
  description = "The ID of the AKS subnet"
  value       = azurerm_subnet.aks_subnet.id
}

# output "bastion_subnet_id" {
#   description = "The ID of the Bastion subnet"
#   value       = azurerm_subnet.bastion_subnet.id
# }

# output "app_gateway_subnet_id" {
#   description = "The ID of the Application Gateway subnet"
#   value       = azurerm_subnet.app_gateway_subnet.id
# }

output "aks_nsg_id" {
  description = "The ID of the AKS Network Security Group"
  value       = azurerm_network_security_group.aks_nsg.id
}
