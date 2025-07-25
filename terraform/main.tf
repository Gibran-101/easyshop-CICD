# -------------------------------- ACR BLOCK -----------------------------------
module "acr" {
  source              = "./modules/acr"
  acr_name            = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "github_actions_secret" "acr_login_server" {
  repository      = var.github_repo
  secret_name     = "ACR_LOGIN_SERVER"
  plaintext_value = module.acr.acr_login_server
}

# -------------------------------- AKS BLOCK -----------------------------------
module "aks" {
  source              = "./modules/aks"
  aks_cluster_name    = var.aks_cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location
  node_count          = var.node_count
  vm_size             = var.vm_size
  kubernetes_version  = var.kubernetes_version
}

# -------------------------------- NETWORK BLOCK -----------------------------------
module "networks" {
  source              = "./modules/networks"
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  subnets             = var.subnets
  nsg_name            = var.nsg_name
  nsg_rules           = var.nsg_rules
}

#------------------------------- LB BLOCK ------------------------------------------
module "loadbalancer" {
  source              = "./modules/loadbalancer"
  public_ip_name      = "easyshop-lb-ip"
  lb_name             = "easyshop-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
}

#---------------------------------DNS_ZONE BLOCK----------------------------------------------
module "dns_zone" {
  source              = "./modules/dns_zone"
  domain_name         = module.dns_zone.domain_name
  record_name         = module.dns_zone.record_name
  resource_group_name = var.resource_group_name
  lb_ip_address       = module.loadbalancer.lb_public_ip_id
}

# -------------------------------- ARGOCD BLOCK -----------------------------------
module "argocd" {
  source              = "./modules/argocd"
  name                = "argocd" # or any logical value you want
  resource_group_name = var.resource_group_name
  location            = var.location
  kubeconfig          = module.aks.kube_config
}


module "image-updater" {
  source              = "./modules/image-updater"
  resource_group_name = var.resource_group_name
  location            = var.location

  acr_name         = module.acr.acr_name
  acr_login_server = module.acr.acr_login_server
  acr_username     = module.acr.acr_admin_username
  acr_password     = module.acr.acr_admin_password

  github_owner    = var.github_owner
  github_repo     = var.github_repo
  github_username = var.github_username
  github_token    = var.github_token

  argocd_server_ip = module.loadbalancer.argocd_server_ip
}


