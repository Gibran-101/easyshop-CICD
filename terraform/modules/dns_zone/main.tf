resource "azurerm_dns_zone" "main" {
  name                = var.domain_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_dns_a_record" "lb_record" {
  name                = var.record_name
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [var.lb_ip_address]
}
