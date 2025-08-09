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

output "static_ip_address" {
  description = "The static IP address for the LoadBalancer"
  value       = azurerm_public_ip.ingress.ip_address
}

output "static_ip_id" {
  description = "The resource ID of the static IP"
  value       = azurerm_public_ip.ingress.id
}

output "static_ip_fqdn" {
  description = "The Azure-provided FQDN"
  value       = azurerm_public_ip.ingress.fqdn
}