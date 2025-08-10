# Create DNS Zone for your domain
resource "azurerm_dns_zone" "dns" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# A Record for root domain using Azure Alias pointing to Static IP resource
resource "azurerm_dns_a_record" "root" {
  name                = "@" # Root domain (buildandship.space)
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  target_resource_id  = var.ingress_public_ip_id # FIXED: Use the variable, not a non-existent resource
  tags                = var.tags
}
