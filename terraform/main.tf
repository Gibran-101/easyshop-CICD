module "acr" {
  source              = "./modules/acr"
  acr_name            = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "aks" {
  source              = "./modules/aks"
  aks_cluster_name    = var.aks_cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location
  node_count          = var.node_count
  vm_size             = var.vm_size
  kubernetes_version  = var.kubernetes_version
}
