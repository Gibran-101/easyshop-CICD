output "resource_group_name" {
  description = "Resource group name"
  value       = module.networking.resource_group_name
}

output "key_vault_name" {
  description = "Application Key Vault name"
  value       = module.app_keyvault.key_vault_name
}

output "key_vault_uri" {
  description = "Application Key Vault URI"
  value       = module.app_keyvault.key_vault_uri
}

output "static_ip_address" {
  description = "The static IP address"
  value       = azurerm_public_ip.ingress_ip.ip_address
}

output "static_ip_fqdn" {
  description = "The Azure FQDN"
  value       = azurerm_public_ip.ingress_ip.fqdn
}

output "dns_nameservers" {
  description = "Nameservers to configure at your domain registrar"
  value       = module.dns.name_servers
}

# output "acr_login_server" {
#   description = "ACR login server"
#   value       = module.acr.acr_login_server
# }

# output "aks_cluster_name" {
#   description = "AKS cluster name"
#   value       = module.aks.cluster_name
# }

# output "aks_cluster_id" {
#   description = "AKS cluster ID"
#   value       = module.aks.cluster_id
# }

# output "dns_zone_name" {
#   description = "DNS zone name"
#   value       = module.dns.dns_zone_name
# }

# output "dns_name_servers" {
#   description = "DNS name servers"
#   value       = module.dns.name_servers
# }

# output "load_balancer_ip" {
#   description = "Load balancer public IP"
#   value       = module.loadbalancer.public_ip_address
# }

# output "argocd_namespace" {
#   description = "ArgoCD namespace"
#   value       = module.argocd.namespace
# }

# output "grafana_url" {
#   description = "Grafana URL"
#   value       = module.observability.grafana_url
# }
