# The main AKS cluster resource
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.aks_cluster_name # Creates: easyshop-aks.eastus.azmk8s.io

  # Use default Kubernetes version (latest supported)
  # kubernetes_version = var.kubernetes_version

  # The default node pool - where your apps run
  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.vm_size
    type            = "VirtualMachineScaleSets"
    os_disk_size_gb = 30
    vnet_subnet_id  = var.vnet_subnet_id
    # orchestrator_version = "1.29.0"     
    node_labels = {
      environment = "dev"
    }
  }

  # Identity configuration - Managed Identity is recommended
  identity {
    type = "SystemAssigned" # Azure creates and manages the identity
  }

  # Network configuration
  network_profile {
    network_plugin    = "azure"       # Azure CNI for better integration
    network_policy    = "azure"       # Network policies for pod-to-pod security
    load_balancer_sku = "standard"    # Standard LB for production features
    service_cidr      = "10.2.0.0/16" # Internal service IPs (don't overlap with VNet)
    dns_service_ip    = "10.2.0.10"   # Internal DNS service IP
  }

  # Enable RBAC for security
  role_based_access_control_enabled = true
}

# Grant AKS access to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}

#Grant AKS access to Key Vault
resource "azurerm_role_assignment" "aks_keyvault_reader" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "Key Vault Secrets User"
  scope                = var.key_vault_id

  depends_on = [azurerm_kubernetes_cluster.aks]
}
