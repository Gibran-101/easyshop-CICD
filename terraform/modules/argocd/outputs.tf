# Auto-generated admin password for initial ArgoCD access
# Retrieved from secret created during ArgoCD installation
output "admin_password" {
  description = "ArgoCD admin password"
  value       = try(data.kubernetes_secret.argocd_admin.data.password, "")
  sensitive   = true
}

# Kubernetes namespace where ArgoCD is installed
# Used by other modules that need to interact with ArgoCD
output "namespace" {
  description = "ArgoCD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

# Internal service URL for ArgoCD server within the cluster
# Used for service-to-service communication and health checks
output "server_url" {
  description = "ArgoCD server URL"
  value       = "argocd-server.${kubernetes_namespace.argocd.metadata[0].name}.svc.cluster.local"
}
