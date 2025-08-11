output "admin_password" {
  description = "ArgoCD admin password"
  value       = try(data.kubernetes_secret.argocd_admin.data.password, "")
  sensitive   = true
}

output "namespace" {
  description = "ArgoCD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "server_url" {
  description = "ArgoCD server URL"
  value       = "argocd-server.${kubernetes_namespace.argocd.metadata[0].name}.svc.cluster.local"
}
