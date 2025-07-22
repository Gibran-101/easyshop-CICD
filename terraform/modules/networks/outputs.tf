output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  value = {
    for k, s in azurerm_subnet.subnet : k => s.id
  }
}

# -------------------------------- NSG OUTPUTS HERE -----------------------------------
output "nsg_id" {
  value = azurerm_network_security_group.nsg.id
}

