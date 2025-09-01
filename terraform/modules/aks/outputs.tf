# Unique Azure resource identifier for the AKS cluster
output "cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.id
}

# Cluster name for reference in other modules or manual operations
output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

# Fully qualified domain name for API server access
output "cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

# Complete kubectl configuration for cluster access - contains sensitive data
# Use: az aks get-credentials instead for local development
output "kube_config" {
  description = "Kubernetes config for connecting to the cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config
  sensitive   = true
}

# Raw kubeconfig as string - useful for CI/CD pipeline integration
output "kube_config_raw" {
  description = "Raw Kubernetes config for connecting to the cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

# Managed identity details for AKS kubelet - needed for role assignments
# Contains client_id, object_id, and user_assigned_identity_id
output "kubelet_identity" {
  description = "The managed identity of the kubelet"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0]
}

# Auto-generated resource group containing AKS infrastructure
# Used for additional role assignments or finding load balancer resources
output "node_resource_group" {
  description = "The auto-generated resource group for AKS nodes"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

# NEW: Key Vault addon identity outputs
output "key_vault_addon_identity" {
  description = "The managed identity created by the Key Vault addon"
  value = {
    client_id   = try(azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].client_id, "")
    object_id   = try(azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].object_id, "")
    resource_id = try(azurerm_kubernetes_cluster.aks.key_vault_secrets_provider[0].secret_identity[0].user_assigned_identity_id, "")
  }
}

# ADD this new output for tracking propagation status:
output "addon_identity_ready" {
  description = "Indicates if the addon identity is ready after propagation delay"
  value       = time_sleep.wait_for_addon_identity.id != "" ? true : false
}