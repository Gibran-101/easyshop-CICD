# Managed Kubernetes cluster for running containerized workloads
# Uses system-assigned identity for Azure service integration and security
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.aks_cluster_name # Creates: easyshop-aks.eastus.azmk8s.io

  # Default node pool where application pods run
  # Optimized for cost with managed disks and proper sizing
  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.vm_size
    type            = "VirtualMachineScaleSets"
    os_disk_size_gb = 30
    vnet_subnet_id  = var.vnet_subnet_id

    # Dynamically configure autoscaling for the AKS node pool.
  # If `enable_auto_scaling` is true, this block sets the minimum and maximum node counts.
  # When autoscaling is disabled, this block is skipped entirely.
    dynamic "autoscale" {
      for_each = var.enable_auto_scaling ? [1] : []
      content {
        min_count = var.min_count
        max_count = var.max_count
      }
    }

    # Node labels for pod scheduling and organization
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
}

# Grant AKS managed identity permission to pull images from ACR
# Eliminates need for manual docker login or stored registry credentials
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}

# Grant AKS access to read secrets from Key Vault
# Enables CSI driver to mount secrets as volumes in pods
resource "azurerm_role_assignment" "aks_keyvault_reader" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "Key Vault Secrets User"
  scope                = var.key_vault_id

  depends_on = [azurerm_kubernetes_cluster.aks]
}
