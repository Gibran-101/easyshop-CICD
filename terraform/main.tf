# Data source to get current Azure client configuration
# Provides tenant ID, subscription ID, and object ID for authentication and resource setup
data "azurerm_client_config" "current" {}

# =======================
# Module: networking
# =======================
# Creates the base networking infrastructure including VNet, subnets, and security groups
# This is the foundation that all other modules depend on
module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
  location     = var.location
  tags         = var.tags
}

# =======================
# Module: Application Key Vault (for storing app secrets)
# =======================
# Creates secure storage for application secrets, keys, and certificates
# Provides centralized secret management with proper access controls
module "app_keyvault" {
  source              = "./modules/vault"
  key_vault_name      = "${var.project_name}-kv01"
  location            = var.location
  resource_group_name = module.networking.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  admin_object_id     = coalesce(var.admin_object_id, data.azurerm_client_config.current.object_id)

  # Simple network ACLs for personal project
  network_acls = {
    default_action             = "Allow" # Allow all for personal project
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = [module.networking.aks_subnet_id]
  }

  tags       = var.tags
  depends_on = [module.networking]
}

# # =======================
# Module: ACR (Container Registry)
# =======================
# Private Docker registry for storing application container images
# Integrates with AKS for seamless image pulls and CI/CD pipelines
module "acr" {
  source              = "./modules/acr"
  acr_name            = var.acr_name
  resource_group_name = module.networking.resource_group_name
  location            = var.location
  tags                = var.tags
  depends_on          = [module.networking]
}

# Store ACR credentials in Application Key Vault for CI/CD access
# Enables automated deployments and secure credential management
# resource "azurerm_key_vault_secret" "acr_admin_username" {
#   name         = "acr-admin-username"
#   value        = module.acr.admin_username
#   key_vault_id = module.app_keyvault.key_vault_id
#   depends_on   = [module.app_keyvault, module.acr]

#   # Lifecycle rule to handle soft-deleted secrets
#   lifecycle {
#     ignore_changes = [
#       value  # Ignore changes to the value if secret already exists
#     ]
#   }
# }

# resource "azurerm_key_vault_secret" "acr_admin_password" {
#   name         = "acr-admin-password"
#   value        = module.acr.admin_password
#   key_vault_id = module.app_keyvault.key_vault_id
#   depends_on   = [module.app_keyvault, module.acr]

#   # Lifecycle rule to handle soft-deleted secrets
#   lifecycle {
#     ignore_changes = [
#       value  # Ignore changes to the value if secret already exists
#     ]
#   }
# }

# =======================
# Module: AKS (Kubernetes Cluster)
# =======================
# Managed Kubernetes cluster for running containerized applications
# Configured with proper networking, security, and Azure service integration
module "aks" {
  source              = "./modules/aks"
  aks_cluster_name    = var.aks_cluster_name
  resource_group_name = module.networking.resource_group_name
  location            = var.location
  vnet_subnet_id      = module.networking.aks_subnet_id
  acr_id              = module.acr.acr_id
  key_vault_id        = module.app_keyvault.key_vault_id
  
  # Fixed: Only pass values when needed
  node_count          = 2
  vm_size             = "Standard_B2s"
  enable_auto_scaling = false
  # Don't pass min_count and max_count when autoscaling is disabled
  # min_count         = null  # Remove this line
  # max_count         = null  # Remove this line

  tags       = var.tags
  depends_on = [module.networking, module.app_keyvault]
}

# =======================
# Static Public IP for Load Balancer - Network Entry Point
# =======================
# Dedicated static IP for the ingress controller load balancer
# Provides stable endpoint for DNS configuration and external access
resource "azurerm_public_ip" "ingress_ip" {
  name                = "${var.project_name}-ingress-ip"
  location            = var.location
  resource_group_name = module.networking.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.project_name}-lb" # Creates: easyshop-lb.eastus.cloudapp.azure.com
  tags                = var.tags

  depends_on = [module.networking] # Only depends on networking
}

# =======================
# Traefik Ingress Installation (Fast & Reliable)
# =======================
resource "null_resource" "install_traefik_ingress" {
  provisioner "local-exec" {
    command = <<EOT
      chmod +x ${path.module}/../scripts/install-traefik.sh
      ${path.module}/../scripts/install-traefik.sh ${azurerm_public_ip.ingress_ip.ip_address} ${module.networking.resource_group_name} ${module.aks.cluster_name}
    EOT
  }

  depends_on = [module.aks, azurerm_public_ip.ingress_ip]

  triggers = {
    static_ip  = azurerm_public_ip.ingress_ip.ip_address
    cluster_id = module.aks.cluster_id
  }
}



# =======================
# Module: DNS (Azure DNS)
# =======================
# Azure DNS zone and records for domain management
# Points the domain to the static IP and manages subdomains
module "dns" {
  source               = "./modules/dns"
  project_name         = var.project_name
  location             = var.location
  dns_zone_name        = var.dns_zone_name
  resource_group_name  = module.networking.resource_group_name
  ingress_public_ip_id = azurerm_public_ip.ingress_ip.id
  tags                 = var.tags

  depends_on = [module.networking, azurerm_public_ip.ingress_ip]
}

# =======================
# Module: ArgoCD
# =======================
# GitOps continuous deployment platform for Kubernetes
# Automatically syncs applications from Git repositories to the cluster
# module "argocd" {
#   source           = "./modules/argocd"
#   kube_config      = module.aks.kube_config
#   argocd_namespace = var.argocd_namespace
#   tags             = var.tags
#   depends_on       = [module.aks]
# }

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
# Automatically updates container image tags in Git repositories
# Enables fully automated CI/CD pipeline from code push to production
# module "argocd_image_updater" {
#   source             = "./modules/argocd-image-updater"
#   kube_config        = module.aks.kube_config
#   argocd_namespace   = var.argocd_namespace
#   acr_login_server   = module.acr.acr_login_server
#   acr_admin_username = module.acr.admin_username
#   acr_admin_password = module.acr.admin_password
#   github_repo_url    = var.github_repo_url
#   tags               = var.tags
#   depends_on         = [module.argocd, module.acr]
# }

# =======================
# Module: Key Vault Secrets - Application Credentials Layer
# =======================
# Generates and stores application-specific secrets in Key Vault
# Creates managed identity for AKS to access secrets via CSI driver
module "keyvault_secrets" {
  source = "./modules/keyvault-secrets"

  project_name                   = var.project_name
  location                       = var.location
  resource_group_name            = module.networking.resource_group_name
  key_vault_id                   = module.app_keyvault.key_vault_id
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  subscription_id                = data.azurerm_client_config.current.subscription_id
  aks_kubelet_identity_object_id = module.aks.kubelet_identity.object_id
  aks_node_resource_group        = module.aks.node_resource_group

  tags = var.tags

  depends_on = [module.app_keyvault, module.aks]
}
