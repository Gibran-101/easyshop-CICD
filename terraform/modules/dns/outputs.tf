# Unique Azure resource identifier for the DNS zone
# Used for advanced DNS configurations and cross-resource references
output "dns_zone_id" {
  description = "DNS Zone resource ID"
  value       = azurerm_dns_zone.dns.id
}

# Domain name of the DNS zone for reference and documentation
# Matches the input variable but useful for module chaining
output "dns_zone_name" {
  description = "DNS Zone name"
  value       = azurerm_dns_zone.dns.name
}

# Name servers that must be configured at your domain registrar
# Critical for DNS functionality - configure these at your domain provider
output "name_servers" {
  description = "Name servers to configure at your domain registrar"
  value       = azurerm_dns_zone.dns.name_servers
}

# FQDN of the root domain A record for verification
# Shows the complete DNS name that resolves to your load balancer
output "root_domain_fqdn" {
  description = "FQDN of the root domain A record"
  value       = "${azurerm_dns_a_record.root.name}.${azurerm_dns_zone.dns.name}"
}