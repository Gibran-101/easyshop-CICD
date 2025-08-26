# Managed Kubernetes cluster for running containerized workloads
# Uses system-assigned identity for Azure service integration and security
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.aks_cluster_name # Creates: easyshop-aks.eastus.azmk8s.io

  # Kubernetes version - using latest stable
  kubernetes_version        = var.kubernetes_version
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  # Default node pool where application pods run
  # Optimized for cost with managed disks and proper sizing
  default_node_pool {
    name            = "default"
    vm_size         = var.vm_size
    type            = "VirtualMachineScaleSets"
    os_disk_size_gb = 30
    vnet_subnet_id  = var.vnet_subnet_id

    # Autoscaling configuration
    node_count = var.enable_auto_scaling ? null : var.node_count
    min_count  = var.enable_auto_scaling ? var.min_count : null
    max_count  = var.enable_auto_scaling ? var.max_count : null

    node_labels = {
      nodepool    = "default"
      workload    = "general"
      environment = "dev"
    }
  }

  # Managed identity for secure Azure service access without stored credentials
  # Automatically rotated and managed by Azure
  identity {
    type = "SystemAssigned"
  }

  # Network configuration optimized for Azure CNI
  # Provides direct pod-to-pod communication and Azure service integration
  network_profile {
    network_plugin    = "azure"       # Azure CNI for better integration
    network_policy    = "azure"       # Network policies for pod-to-pod security
    load_balancer_sku = "standard"    # Standard LB for production features
    service_cidr      = "10.2.0.0/16" # Internal service IPs (don't overlap with VNet)
    dns_service_ip    = "10.2.0.10"   # Internal DNS service IP
  }

  # Enable RBAC for granular access control to cluster resources
  role_based_access_control_enabled = true

  # CRITICAL: Enable Key Vault secrets provider addon
  # This creates the managed identity we'll use for CSI driver
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
}

# Grant AKS managed identity permission to pull images from ACR
# Eliminates need for manual docker login or stored registry credentials
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Grant AKS addon identity access to Key Vault secrets
# This uses the addon identity instead of kubelet identity
resource "azurerm_role_assignment" "aks_addon_keyvault_access" {
  principal_id         = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].object_id
  role_definition_name = "Key Vault Secrets User"
  scope                = var.key_vault_id

  depends_on = [azurerm_kubernetes_cluster.aks]
}

#Grant AKS addon identity access to Key Vault secrets
resource "azurerm_role_assignment" "aks_addon_keyvault_access" {
  principal_id         = azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].object_id
  role_definition_name = "Key Vault Secrets User"
  scope                = var.key_vault_id
  
  depends_on = [azurerm_kubernetes_cluster.aks]
  
  # Prevent issues with identity propagation
  skip_service_principal_aad_check = true
}