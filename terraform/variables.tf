variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "The size of the virtual machines in the AKS node pool"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the AKS cluster"
  type        = string
  default     = "1.28.3"
}
