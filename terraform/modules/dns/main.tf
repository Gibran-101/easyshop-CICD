# Create a static public IP for the LoadBalancer
resource "azurerm_public_ip" "ingress" {
  name                = "${var.project_name}-ingress-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"               # Must be Standard for AKS LoadBalancer
  domain_name_label   = "${var.project_name}-lb" # Creates: easyshop-lb.eastus.cloudapp.azure.com
  tags                = var.tags
}

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
  target_resource_id  = azurerm_public_ip.ingress.id # Points to our static IP resource
  tags                = var.tags
}

# Optional: Add www subdomain that redirects to root
resource "azurerm_dns_cname_record" "www" {
  count               = var.create_www_redirect ? 1 : 0
  name                = "www"
  zone_name           = azurerm_dns_zone.dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = var.dns_zone_name # www.buildandship.space -> buildandship.space
  tags                = var.tags
}