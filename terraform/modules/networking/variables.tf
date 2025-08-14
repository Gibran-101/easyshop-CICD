# Prefix for all resource names - keeps resources organized and identifiable
# Should be short, lowercase, no spaces. Example: "easyshop", "myproject"
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Azure region where all networking resources will be created
# Must match the region used by other modules. Example: "East US", "West Europe"
variable "location" {
  description = "Azure region"
  type        = string
}

# Standard Azure tags applied to all networking resources
# Useful for cost tracking, ownership, and governance
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
