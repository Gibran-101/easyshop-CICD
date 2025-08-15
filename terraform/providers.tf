# =======================
# Azure Resource Manager Provider
# =======================
# Main provider for creating and managing Azure resources
# Handles authentication, resource lifecycle, and Azure API interactions
provider "azurerm" {
  features {
    # Key Vault configuration for secure secret management
    key_vault {
      # Don't auto-purge soft-deleted vaults to prevent accidental data loss
      purge_soft_delete_on_destroy    = false
      # Allow recovery of soft-deleted Key Vaults during deployment
      recover_soft_deleted_key_vaults = true
    }
    
    # Resource group configuration
    resource_group {
      # Allow Terraform to delete resource groups even if they contain resources
      # Useful for clean teardown but use with caution in production
      prevent_deletion_if_contains_resources = true
    }
  }
  
  # Azure credentials are provided via environment variables (ARM_*)
  # These are automatically set by GitHub Actions or local Azure CLI login
  # Required variables:
  # - ARM_CLIENT_ID: Service principal application ID
  # - ARM_CLIENT_SECRET: Service principal password
  # - ARM_SUBSCRIPTION_ID: Azure subscription ID  
  # - ARM_TENANT_ID: Azure AD tenant ID
}

# =======================
# Kubernetes Provider
# =======================
# Manages Kubernetes resources after AKS cluster is created
# Configured dynamically using AKS cluster credentials
provider "kubernetes" {
  # Connection details are populated after AKS cluster creation
  # Uses try() function to handle initial state when cluster doesn't exist yet
  host                   = try(module.aks.kube_config[0].host, "")
  client_certificate     = try(base64decode(module.aks.kube_config[0].client_certificate), "")
  client_key             = try(base64decode(module.aks.kube_config[0].client_key), "")
  cluster_ca_certificate = try(base64decode(module.aks.kube_config[0].cluster_ca_certificate), "")
}

# =======================
# Helm Provider
# =======================
# Deploys Helm charts to Kubernetes cluster (ArgoCD, NGINX Ingress, etc.)
# Uses same authentication as Kubernetes provider for consistency
provider "helm" {
  kubernetes {
    # Same connection configuration as Kubernetes provider
    # Ensures Helm can deploy charts to the AKS cluster
    host                   = try(module.aks.kube_config[0].host, "")
    client_certificate     = try(base64decode(module.aks.kube_config[0].client_certificate), "")
    client_key             = try(base64decode(module.aks.kube_config[0].client_key), "")
    cluster_ca_certificate = try(base64decode(module.aks.kube_config[0].cluster_ca_certificate), "")
  }
}
