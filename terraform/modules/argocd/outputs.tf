output "argocd_server_url" {
  value = helm_release.argocd.status[0].load_balancer[0].ingress[0].hostname
}
