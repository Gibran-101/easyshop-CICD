output "acr_login_server" {
  value = module.acr.acr_login_server
}

#------------------------------------- AKS OUTPUTS HERE ---------------------------------------
output "aks_name" {
  value = module.aks.aks_name
}

output "kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}

output "argocd_server_ip" {
  value = module.aks.argocd_server_ip
}

# -------------------------------- NETWORK OUTPUTS HERE -----------------------------------
output "vnet_id" {
  value = module.networks.vnet_id
}

output "subnet_ids" {
  value = module.networks.subnet_ids
}

#-------------------- ACR VARS FOR ARGOCD IMAGE UPDATER --------------------------
output "acr_login_server" {
  value = module.acr.acr_login_server
}
output "acr_username" {
  value = module.acr.acr_admin_username
}
output "acr_password" {
  value = module.acr.acr_admin_password
}

