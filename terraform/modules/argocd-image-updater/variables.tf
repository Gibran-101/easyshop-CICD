#Kubernetes configuration form AKS module - continas cluster coection details
variable "kube_config" {
  description = "Kubernetes configuration from AKS"
  type        = any
  sensitive   = true
}

# ArgoCD namespace where Image Updater will be installed
# Must be the same namespace as ArgoCD installation
variable "argocd_namespace" {
  description = "ArgoCD namespace"
  type        = string
  default     = "argocd"
}

# Log level for Image Updater - useful for troubleshooting
# Options: trace, debug, info, warn, error
variable "log_level" {
  description = "Log level for ArgoCD Image Updater"
  type        = string
  default     = "info"
  validation {
    condition     = contains(["trace", "debug", "info", "warn", "error"], var.log_level)
    error_message = "Log level must be one of: trace, debug, info, warn, error."
  }
}

# ACR login server URL from ACR module
# Format: registryname.azurecr.io
variable "acr_login_server" {
  description = "ACR login server URL"
  type        = string
}

# ACR admin username for registry authentication
variable "acr_admin_username" {
  description = "ACR admin username"
  type        = string
}

# ACR admin password for registry authentication - highly sensitive
variable "acr_admin_password" {
  description = "ACR admin password"
  type        = string
  sensitive   = true
}

# GitHub repository URL for Git write-back operations
variable "github_repo_url" {
  description = "GitHub repository URL"
  type        = string
}

# Default update strategy for applications
# Options: semver, latest, name, digest
variable "default_update_strategy" {
  description = "Default update strategy for applications"
  type        = string
  default     = "semver"
  validation {
    condition     = contains(["semver", "latest", "name", "digest"], var.default_update_strategy)
    error_message = "Update strategy must be one of: semver, latest, name, digest."
  }
}

# Standard Azure tags for resource organization
variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}