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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "ingress_public_ip_id" {
  description = "Resource ID of the static public IP (passed from main.tf)"
  type        = string
}
