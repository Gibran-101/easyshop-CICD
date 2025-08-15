# Project name for consistent resource naming and organization
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

# The domain name for which DNS zone will be created
# Must be a valid domain that you own. Example: "buildandship.space", "mycompany.com"
variable "dns_zone_name" {
  description = "The DNS zone name (your domain)"
  type        = string
}

# Resource group where DNS zone and records will be created
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# Azure region for resource metadata (DNS is global, but resources need a location)
variable "location" {
  description = "Azure region"
  type        = string
}

# Standard Azure tags for resource organization and cost tracking
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Resource ID of the static public IP that the domain should point to
# Typically the load balancer IP from the main infrastructure
variable "ingress_public_ip_id" {
  description = "Resource ID of the static public IP (passed from main.tf)"
  type        = string
}
