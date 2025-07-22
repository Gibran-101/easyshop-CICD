output "dns_zone_name" {
  value = azurerm_dns_zone.main.name
}

output "dns_record_fqdn" {
  value = azurerm_dns_a_record.lb_record.fqdn
}
