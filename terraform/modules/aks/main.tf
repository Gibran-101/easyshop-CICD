# Managed Kubernetes cluster for running containerized workloads
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.aks_cluster_name

  kubernetes_version        = var.kubernetes_version
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  default_node_pool {
    name            = "default"
    vm_size         = var.vm_size
    type            = "VirtualMachineScaleSets"
    os_disk_size_gb = 30
    vnet_subnet_id  = var.vnet_subnet_id

    node_count = var.enable_auto_scaling ? null : var.node_count
    min_count  = var.enable_auto_scaling ? var.min_count : null
    max_count  = var.enable_auto_scaling ? var.max_count : null

    node_labels = {
      nodepool    = "default"
      workload    = "general"
      environment = "dev"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.2.0.0/16"
    dns_service_ip    = "10.2.0.10"
  }

  role_based_access_control_enabled = true

  # CRITICAL: Properly configured Key Vault secrets provider addon
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = var.key_vault_secret_rotation_interval
  }

  tags = var.tags
}

# Grant AKS managed identity permission to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}

# CRITICAL: Wait for identity propagation before setting Key Vault access
resource "time_sleep" "wait_for_addon_identity" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  
  create_duration = "60s"  # Wait for Azure AD propagation
  
  triggers = {
    # Recreate if the cluster or addon changes
    cluster_id = azurerm_kubernetes_cluster.aks.id
    addon_identity = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].object_id
  }
}

# Grant AKS addon identity access to Key Vault secrets with proper timing
resource "azurerm_role_assignment" "aks_addon_keyvault_access" {
  principal_id         = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].object_id
  role_definition_name = "Key Vault Secrets User"
  scope                = var.key_vault_id

  skip_service_principal_aad_check = true
  
  lifecycle {
    create_before_destroy = true
  }
  
  depends_on = [
    azurerm_kubernetes_cluster.aks,
    time_sleep.wait_for_addon_identity  # Wait for identity propagation
  ]
}
