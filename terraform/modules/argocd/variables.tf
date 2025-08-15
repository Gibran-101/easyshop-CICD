# Kubernetes configuration from AKS module - contains cluster connection details
# Includes API server endpoint, certificates, and authentication tokens
variable "kube_config" {
  description = "Kubernetes configuration from AKS"
  type        = any
  sensitive   = true
}

# Kubernetes namespace where ArgoCD will be installed
# Standard practice is "argocd" but can be customized for multi-tenant setups
variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

# ArgoCD Helm chart version for consistent deployments
# Pin to specific version to avoid unexpected updates during terraform apply
variable "argocd_chart_version" {
  description = "Version of ArgoCD Helm chart to install"
  type        = string
  default     = "5.51.4"
}

# Standard Azure tags for resource organization and cost tracking
variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}