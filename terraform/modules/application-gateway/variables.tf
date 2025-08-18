# Project name for consistent resource naming and organization
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Resource group where Application Gateway will be created
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# Azure region for Application Gateway deployment
variable "location" {
  description = "Azure region"
  type        = string
}

# Dedicated subnet ID for Application Gateway (from networking module)
variable "app_gateway_subnet_id" {
  description = "ID of the subnet for Application Gateway"
  type        = string
}

# Public IP resource ID for Application Gateway frontend
variable "public_ip_id" {
  description = "ID of the public IP for Application Gateway"
  type        = string
}

# Domain name for SSL certificate and routing configuration
variable "dns_zone_name" {
  description = "DNS zone name for SSL certificates and routing"
  type        = string
}

# Key Vault ID for storing SSL certificates (if using Azure managed certs)
variable "key_vault_id" {
  description = "Key Vault ID for storing SSL certificates"
  type        = string
  default     = ""
}

# Application Gateway SKU configuration for performance and features
variable "sku_tier" {
  description = "Application Gateway SKU tier"
  type        = string
  default     = "Standard_v2"
  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_tier)
    error_message = "SKU tier must be Standard_v2 or WAF_v2."
  }
}

# Enable Web Application Firewall for enhanced security
variable "enable_waf" {
  description = "Enable Web Application Firewall (requires WAF_v2 SKU)"
  type        = bool
  default     = false
}

# Auto-scaling configuration for handling traffic spikes
variable "autoscale_config" {
  description = "Auto-scaling configuration"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = {
    min_capacity = 1
    max_capacity = 3
  }
}

# SSL policy for security and compliance
variable "ssl_policy" {
  description = "SSL policy configuration"
  type = object({
    policy_type = string
    policy_name = optional(string)
  })
  default = {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101S"
  }
}

# Backend configuration for AKS integration
variable "backend_fqdn" {
  description = "Backend FQDN for AKS service (will be auto-discovered by AGIC)"
  type        = string
  default     = ""
}

# Health check configuration
variable "health_probe_config" {
  description = "Health probe configuration"
  type = object({
    path                = string
    interval            = number
    timeout             = number
    unhealthy_threshold = number
    status_codes        = list(string)
  })
  default = {
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    status_codes        = ["200-399"]
  }
}

# Standard Azure tags for resource organization and cost tracking
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}