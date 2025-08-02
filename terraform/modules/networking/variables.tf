variable "project_name" {
  description = "Prefix for all resources"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "East US"
}
