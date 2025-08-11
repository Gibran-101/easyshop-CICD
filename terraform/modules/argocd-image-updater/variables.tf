variable "kube_config" {
  description = "Kubernetes configuration from AKS"
  type        = any
  sensitive   = true
}

variable "argocd_namespace" {
  description = "ArgoCD namespace"
  type        = string
  default     = "argocd"
}

variable "acr_login_server" {
  description = "ACR login server URL"
  type        = string
}

variable "acr_admin_username" {
  description = "ACR admin username"
  type        = string
}

variable "acr_admin_password" {
  description = "ACR admin password"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repository URL"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}