output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "aks_name" {
  value = module.aks.aks_name
}

output "kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}
