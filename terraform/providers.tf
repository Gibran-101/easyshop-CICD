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
      purge_soft_delete_on_destroy = false
      # Allow recovery of soft-deleted Key Vaults during deployment
      recover_soft_deleted_key_vaults = false
    }

    # Resource group configuration
    resource_group {
      # Allow Terraform to delete resource groups even if they contain resources
      # Useful for clean teardown but use with caution in production
      prevent_deletion_if_contains_resources = false
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
