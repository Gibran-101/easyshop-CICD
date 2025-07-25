output "lb_public_ip_id" {
  value = azurerm_public_ip.lb_public_ip.id
}

output "lb_id" {
  value = azurerm_lb.lb.id
}

output "argocd_server_ip" {
  value = kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].ip
}
