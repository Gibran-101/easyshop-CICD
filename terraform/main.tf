# Data source to get current Azure client configuration
data "azurerm_client_config" "current" {}

# =======================
# Module: networking
# =======================
module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
  location     = var.location
  tags         = var.tags
}

# =======================
# Module: Application Key Vault (for storing app secrets)
# =======================
module "app_keyvault" {
  source              = "./modules/vault"
  key_vault_name      = "${var.project_name}-kv"
  location            = var.location
  resource_group_name = module.networking.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  admin_object_id     = coalesce(var.admin_object_id, data.azurerm_client_config.current.object_id)

  # Simple network ACLs for personal project
  network_acls = {
    default_action             = "Allow" # Allow all for personal project
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ips # Add your home IP if you want
    virtual_network_subnet_ids = [module.networking.aks_subnet_id]
  }

  tags       = var.tags
  depends_on = [module.networking]
}

# # =======================
# Module: ACR (Container Registry)
# =======================
module "acr" {
  source              = "./modules/acr"
  acr_name            = var.acr_name
  resource_group_name = module.networking.resource_group_name
  location            = var.location
  tags                = var.tags
  depends_on          = [module.networking]
}

# Store ACR credentials in Application Key Vault
resource "azurerm_key_vault_secret" "acr_admin_username" {
  name         = "acr-admin-username"
  value        = module.acr.admin_username
  key_vault_id = module.app_keyvault.key_vault_id
  depends_on   = [module.app_keyvault, module.acr]
}

resource "azurerm_key_vault_secret" "acr_admin_password" {
  name         = "acr-admin-password"
  value        = module.acr.admin_password
  key_vault_id = module.app_keyvault.key_vault_id
  depends_on   = [module.app_keyvault, module.acr]
}

# =======================
# Module: AKS (Kubernetes Cluster)
# =======================
module "aks" {
  source              = "./modules/aks"
  aks_cluster_name    = var.aks_cluster_name
  resource_group_name = module.networking.resource_group_name
  location            = var.location
  vnet_subnet_id      = module.networking.aks_subnet_id
  acr_id              = module.acr.acr_id
  key_vault_id        = module.app_keyvault.key_vault_id
  node_count          = 2
  vm_size             = "Standard_B2s"
  enable_auto_scaling = false


  tags       = var.tags
  depends_on = [module.networking, module.app_keyvault] #remember to add acr here
}

resource "helm_release" "nginx_ingress_controller" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.3"
  namespace  = "ingress-nginx"

  create_namespace = true

  # This creates a LoadBalancer with Azure FQDN
  # Tell NGINX to use the static IP
  set {
    name  = "controller.service.loadBalancerIP"
    value = module.dns.static_ip_address
  }

  depends_on = [module.aks]
}

# Get the LoadBalancer details
data "kubernetes_service" "nginx_lb" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [helm_release.nginx_ingress_controller]
}


# =======================
# Module: DNS (Azure DNS)
# =======================
module "dns" {
  source              = "./modules/dns"
  project_name        = var.project_name
  location            = var.location
  dns_zone_name       = var.dns_zone_name
  resource_group_name = module.networking.resource_group_name
  tags                = var.tags

  depends_on = [module.networking, helm_release.nginx_ingress_controller]
}

# =======================
# Module: ArgoCD
# =======================
module "argocd" {
  source           = "./modules/argocd"
  kube_config      = module.aks.kube_config
  argocd_namespace = var.argocd_namespace
  tags             = var.tags
  depends_on       = [module.aks]
}

# # Store ArgoCD password in Application Key Vault
# resource "azurerm_key_vault_secret" "argocd_admin_password" {
#   name         = "argocd-admin-password"
#   value        = module.argocd.admin_password
#   key_vault_id = module.app_keyvault.key_vault_id
#   depends_on   = [module.app_keyvault, module.argocd]
# }

# =======================
# Module: ArgoCD Image Updater
# =======================
module "argocd_image_updater" {
  source             = "./modules/argocd-image-updater"
  kube_config        = module.aks.kube_config
  argocd_namespace   = var.argocd_namespace
  acr_login_server   = module.acr.acr_login_server
  acr_admin_username = module.acr.admin_username
  acr_admin_password = module.acr.admin_password
  github_repo_url    = var.github_repo_url
  tags               = var.tags
  depends_on         = [module.argocd, module.acr]
}

# # =======================
# # Module: Observability (Grafana, Prometheus, Loki)
# # =======================
# module "observability" {
#   source           = "./modules/observability"
#   kube_config      = module.aks.kube_config
#   observability_ns = var.observability_namespace
#   tags             = var.tags
#   depends_on       = [module.aks]
# }