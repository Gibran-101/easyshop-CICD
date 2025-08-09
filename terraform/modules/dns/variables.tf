variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "dns_zone_name" {
  description = "The DNS zone name (your domain)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "create_www_redirect" {
  description = "Create www subdomain redirect"
  type        = bool
  default     = false # Keep it simple - just root domain
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}