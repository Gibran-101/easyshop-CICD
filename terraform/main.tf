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
  domain_name         = "mydomain.com"
  record_name         = "app"
  resource_group_name = var.resource_group_name
  lb_ip_address       = module.loadbalancer.lb_public_ip_id
}
