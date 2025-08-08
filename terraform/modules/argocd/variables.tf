variable "kube_config" {
  description = "Kubernetes configuration from AKS"
  type        = any
  sensitive   = true
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}