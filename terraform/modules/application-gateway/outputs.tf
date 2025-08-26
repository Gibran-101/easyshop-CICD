# Unique Azure resource identifier for the Application Gateway
output "application_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.this.id
}

# Application Gateway name for CLI operations and references
output "application_gateway_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.this.name
}

# Resource group name where Application Gateway is deployed
output "resource_group_name" {
  description = "Resource group name of the Application Gateway"
  value       = azurerm_application_gateway.this.resource_group_name
}

# Backend address pool information for AGIC configuration
output "backend_address_pools" {
  description = "Backend address pools configuration"
  value = {
    for pool in azurerm_application_gateway.this.backend_address_pool :
    pool.name => {
      id   = pool.id
      name = pool.name
    }
  }
}

# Frontend IP configuration details
output "frontend_ip_configuration" {
  description = "Frontend IP configuration details"
  value = {
    name               = azurerm_application_gateway.this.frontend_ip_configuration[0].name
    public_ip_id       = var.public_ip_id
    private_ip_address = azurerm_application_gateway.this.frontend_ip_configuration[0].private_ip_address
  }
}

# SSL certificate information
output "ssl_certificates" {
  description = "SSL certificates configured on Application Gateway"
  value = {
    for cert in azurerm_application_gateway.this.ssl_certificate :
    cert.name => {
      name = cert.name
      id   = cert.id
    }
  }
  sensitive = true
}

# HTTP listeners information for advanced configurations
output "http_listeners" {
  description = "HTTP listeners configured on Application Gateway"
  value = {
    for listener in azurerm_application_gateway.this.http_listener :
    listener.name => {
      name          = listener.name
      id            = listener.id
      protocol      = listener.protocol
      frontend_port = listener.frontend_port_name
    }
  }
}

# Application Gateway public FQDN (if available)
output "public_fqdn" {
  description = "Public FQDN of the Application Gateway"
  value       = var.dns_zone_name
}

# Health probe configuration for monitoring
output "health_probes" {
  description = "Health probes configured on Application Gateway"
  value = {
    for probe in azurerm_application_gateway.this.probe :
    probe.name => {
      name     = probe.name
      path     = probe.path
      protocol = probe.protocol
    }
  }
}

# WAF status (if enabled)
output "waf_enabled" {
  description = "Whether Web Application Firewall is enabled"
  value       = var.enable_waf
}

# Auto-scaling configuration
output "autoscale_configuration" {
  description = "Auto-scaling configuration"
  value = {
    min_capacity = var.autoscale_config.min_capacity
    max_capacity = var.autoscale_config.max_capacity
  }
}

output "agic_identity_client_id" {
  value = azurerm_user_assigned_identity.agic_identity.client_id
}