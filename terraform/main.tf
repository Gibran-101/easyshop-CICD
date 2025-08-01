provider "azurerm" {
  features {}
}

# =======================
# Module: networking
# =======================
module "networking" {
  source = "./modules/networking"
  vnet_name           = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# =======================
# Module: acr (Container Registry)
# =======================
module "acr" {
  source = "./modules/acr"
  acr_name            = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# =======================
# Module: aks (Kubernetes Cluster)
# =======================
module "aks" {
  source = "./modules/aks"
  aks_cluster_name    = var.aks_cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_subnet_id      = module.networking.subnet_id
  acr_id              = module.acr.acr_id
  tags                = var.tags
  depends_on = [module.networking, module.acr]
}

# =======================
# Module: dns (Azure DNS)
# =======================
module "dns" {
  source = "./modules/dns"
  dns_zone_name       = var.dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# =======================
# Module: loadbalancer
# =======================
module "loadbalancer" {
  source = "./modules/loadbalancer"
  aks_cluster_name    = var.aks_cluster_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# =======================
# Module: argocd
# =======================
module "argocd" {
  source = "./modules/argocd"
  aks_kube_config     = module.aks.kube_config
  argocd_namespace    = var.argocd_namespace
  tags                = var.tags
  depends_on = [module.aks]
}

# =======================
# Module: argocd-image-updater
# =======================
module "argocd_image_updater" {
  source = "./modules/argocd-image-updater"
  acr_login_server     = module.acr.acr_login_server
  argocd_namespace     = var.argocd_namespace
  github_repo_url      = var.github_repo_url
  tags                 = var.tags
  depends_on = [module.argocd, module.acr]
}

# =======================
# Module: observability (Grafana, Prometheus, Loki)
# =======================
module "observability" {
  source = "./modules/observability"
  aks_kube_config      = module.aks.kube_config
  observability_ns     = var.observability_namespace
  tags                 = var.tags
  depends_on = [module.aks]
}

# =======================
# Module: vault (HashiCorp Vault)
# =======================
module "vault" {
  source = "./modules/vault"
  aks_kube_config      = module.aks.kube_config
  vault_namespace      = var.vault_namespace
  tags                 = var.tags
  depends_on = [module.aks]
}
