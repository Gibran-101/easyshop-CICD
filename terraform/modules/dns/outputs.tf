output "dns_zone_id" {
  description = "DNS Zone resource ID"
  value       = azurerm_dns_zone.dns.id
}

output "dns_zone_name" {
  description = "DNS Zone name"
  value       = azurerm_dns_zone.dns.name
}

output "name_servers" {
  description = "Name servers to configure at your domain registrar"
  value       = azurerm_dns_zone.dns.name_servers
}
