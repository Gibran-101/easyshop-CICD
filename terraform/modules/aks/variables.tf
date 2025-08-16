# Name of the AKS cluster - should be descriptive and unique within resource group
variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

# Resource group where AKS cluster will be created - must already exist
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# Azure region for AKS cluster - must match networking module region
variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
}

# Subnet ID where AKS nodes will be deployed - from networking module
variable "vnet_subnet_id" {
  description = "ID of the subnet where AKS nodes will be deployed"
  type        = string
}

# ACR resource ID for granting image pull permissions to AKS
variable "acr_id" {
  description = "ID of the Azure Container Registry"
  type        = string
}

# Optional Key Vault ID for CSI driver integration - leave empty to skip
variable "key_vault_id" {
  description = "ID of the Key Vault (optional)"
  type        = string
  default     = ""
}

# Kubernetes version for cluster and nodes - use latest stable for security
variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.30.0" # Use latest stable version
}

# Number of worker nodes - start small for cost, scale up as needed
variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

# VM size for nodes - B-series for cost, D-series for performance
variable "vm_size" {
  description = "Size of the VMs in the default node pool"
  type        = string
  default     = "Standard_D2_v2" # 2 vCPU, 7GB RAM
}

# Enable auto-scaling to handle variable workloads and optimize costs
variable "enable_auto_scaling" {
  description = "Enable auto-scaling for the default node pool"
  type        = bool
  default     = true # Set to true for production
}

# Minimum nodes when auto-scaling enabled - keep low for cost control
variable "min_count" {
  description = "Minimum number of nodes when auto-scaling is enabled"
  type        = number
  default     = null
}

# Maximum nodes when auto-scaling enabled - set based on workload needs
variable "max_count" {
  description = "Maximum number of nodes when auto-scaling is enabled"
  type        = number
  default     = null
}

# Azure AD group IDs for cluster admin access - leave empty for basic setup
variable "admin_group_object_ids" {
  description = "Azure AD group object IDs for cluster admin access"
  type        = list(string)
  default     = []
}

# Standard Azure tags for resource management and cost tracking
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
