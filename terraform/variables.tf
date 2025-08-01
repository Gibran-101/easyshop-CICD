variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
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

# variable "kubelet_identity_object_id" {
#   description = "Managed identity object ID for kubelet"
#   type        = string
# }

# variable "acr_id" {
#   description = "Azure Container Registry ID"
#   type        = string
# }


#-------------------------------------- ACR VARIABLES HERE ------------------------------------------------
variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub account/org name"
}

variable "github_repo" {
  description = "GitHub repository name"
}

# -------------------------------- NETWORK VARIABLES HERE -----------------------------------
variable "vnet_name" {
  default     = "es-vnet"
  description = "VNet name"
  type        = string
}

variable "vnet_address_space" {
  default     = ["10.0.0.0/16"]
  description = "Address space for the VNet"
  type        = list(string)
}

variable "subnets" {
  default = {
    "app-subnet"   = ["10.0.1.0/24"]
    "db-subnet"    = ["10.0.2.0/24"]
    "redis-subnet" = ["10.0.3.0/24"]
  }
  description = "Subnets map"
  type        = map(list(string))
}

variable "nsg_name" {
  type = string
}

variable "nsg_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}

#------------------------------- LB VARIABLES ------------------------------------------
variable "public_ip_name" {
  type        = string
  description = "Name of the public IP for LB"
}

variable "lb_name" {
  type        = string
  description = "Name of the Load Balancer"
}

#--------------------------------------DNS_ZONE VARIABLES--------------------------------------------
variable "domain_name" {
  type        = string
  description = "DNS zone domain name (e.g., mydomain.com)"
}

variable "record_name" {
  type        = string
  description = "Subdomain (e.g., www, app)"
}

#--------------------------------- ARGOCD VARIABLES ----------------------------------------------------
variable "name" {
  description = "The name of the ArgoCD module or deployment"
  type        = string
}

# variable "kubeconfig" {
#   description = "Kubeconfig to connect to AKS"
#   type        = string
#   sensitive   = true
# }

#--------------------------IMAGE UPDATER VARIABLES ---------------------------------

variable "github_username" {
  description = "GitHub username used for ArgoCD image updater"
  type        = string
}

