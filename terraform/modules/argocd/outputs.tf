# output "argocd_server_url" {
#   value       = data.kubernetes_service.argocd_server.status[0].load_balancer[0].ip
#   description = "ArgoCD LoadBalancer IP"
# }

output "argocd_service_debug" {
  value = data.kubernetes_service.argocd_server.status
}

