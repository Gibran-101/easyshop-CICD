# Key Vault Module

## Overview
Creates an Azure Key Vault for secure storage and management of application secrets, encryption keys, and certificates. This module provides enterprise-grade secret management with fine-grained access control, audit logging, and network security features optimized for both personal projects and production environments.

## Purpose
- Centralized storage for application secrets (database passwords, API keys, tokens)
- Secure key management for encryption and digital signing operations
- SSL/TLS certificate lifecycle management and automatic renewal
- Integration with Azure services and Kubernetes applications
- Compliance and audit logging for security and regulatory requirements

## When to Use
Use this module when you need:
- Secure storage for application credentials and configuration secrets
- Integration with AKS via CSI Secret Store driver for pod secret mounting
- Centralized certificate management for SSL/TLS and code signing
- Audit logging and compliance for secret access and modifications
- Network-isolated secret storage with IP or VNet restrictions

## Dependencies
- **Resource group** (typically from networking module)
- **Azure AD tenant** for authentication and access control
- **Log Analytics workspace** (optional, for diagnostic logging)

## What Depends on This Module
- **Key Vault Secrets module** - Stores application-specific secrets and credentials
- **AKS module** - Uses managed identity for CSI Secret Store driver access
- **Application deployments** - Reference secrets via CSI driver or SDK
- **CI/CD pipelines** - Store deployment credentials and API keys

## Example Usage

### Basic Setup (Personal Projects)
```hcl
module "app_keyvault" {
  source              = "./modules/vault"
  key_vault_name      = "easyshop-kv"
  location            = "East US"
  resource_group_name = module.networking.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  admin_object_id     = data.azurerm_client_config.current.object_id

  # Simple public access for development
  network_acls = {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}
```

### Production Setup (Enhanced Security)
```hcl
module "app_keyvault" {
  source              = "./modules/vault"
  key_vault_name      = "company-prod-kv"
  location            = "East US"
  resource_group_name = module.networking.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  admin_object_id     = data.azurerm_client_config.current.object_id

  # Enhanced security settings
  sku_name                    = "premium"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 90

  # Restricted network access
  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [module.networking.aks_subnet_id]
    ip_rules                   = ["203.0.113.0/24"]  # Office IP range
  }

  # Enable monitoring
  enable_diagnostics         = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  # Additional access for team members
  additional_access_policies = [
    {
      object_id          = "user-object-id-1"
      secret_permissions = ["Get", "List"]
    }
  ]

  tags = var.tags
}
```

## Key Vault Architecture
```
Key Vault
├── Secrets (Database passwords, API keys, tokens)
├── Keys (Encryption keys, signing keys)
├── Certificates (SSL/TLS certs, code signing certs)
├── Access Policies (Who can access what)
├── Network ACLs (IP/VNet restrictions)
└── Audit Logs (Who accessed what, when)

Integration Points:
├── AKS CSI Driver → Mount secrets as files in pods
├── Azure Services → Automatic managed identity authentication
├── Applications → SDK/REST API access with Azure AD
└── ARM Templates → Deployment-time secret retrieval
```

## Security Features

### Access Control
- **Azure AD Integration**: Native authentication with Azure Active Directory
- **Access Policies**: Granular permissions per user, group, or application
- **Managed Identity Support**: Passwordless access for Azure services
- **RBAC Integration**: Role-based access control for simplified management

### Network Security
- **Public Access**: Simple setup, accessible from internet with proper authentication
- **IP Restrictions**: Allow only specific IP addresses or CIDR ranges
- **VNet Integration**: Access restricted to specific virtual network subnets
- **Azure Service Bypass**: Allow Azure services to access even with restrictions

### Data Protection
- **Encryption at Rest**: All data encrypted with Microsoft-managed or customer-managed keys
- **Encryption in Transit**: TLS 1.2+ for all communications
- **Soft Delete**: Recoverable deletion with configurable retention period (7-90 days)
- **Purge Protection**: Prevents permanent deletion even by administrators

## Integration with AKS
```yaml
# Example: CSI Secret Store driver configuration
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: app-secrets
spec:
  provider: azure
  parameters:
    keyvaultName: "easyshop-kv"
    tenantId: "your-tenant-id"
    objects: |
      array:
        - |
          objectName: database-password
          objectType: secret
```

## Common Operations

### CLI Access
```bash
# Login to Azure
az login

# List all secrets
az keyvault secret list --vault-name easyshop-kv

# Get secret value
az keyvault secret show --vault-name easyshop-kv --name database-password --query value -o tsv

# Set a new secret
az keyvault secret set --vault-name easyshop-kv --name api-key --value "your-secret-value"

# Grant access to a user
az keyvault set-policy --name easyshop-kv \
  --upn user@domain.com \
  --secret-permissions get list
```

### Common Issues
- **Access Denied Errors**: Check access policies and ensure correct object IDs
- **Network Connectivity**: Verify VNet configurations and firewall rules
- **Soft Delete Conflicts**: Purge deleted resources before creating with same name
- **Certificate Renewal**: Monitor certificate expiration dates and renewal processes

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_object_id"></a> [admin\_object\_id](#input\_admin\_object\_id) | Object ID of the admin user/service principal | `string` | n/a | yes |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Name of the Key Vault (must be globally unique) | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Key Vault | `string` | n/a | yes |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Network ACLs for Key Vault (optional) | <pre>object({<br/>    default_action             = string<br/>    bypass                     = string<br/>    ip_rules                   = optional(list(string), [])<br/>    virtual_network_subnet_ids = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "bypass": "AzureServices",<br/>  "default_action": "Allow",<br/>  "ip_rules": [],<br/>  "virtual_network_subnet_ids": []<br/>}</pre> | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the Key Vault | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Azure AD tenant ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The ID of the Key Vault |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Key Vault |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | The URI of the Key Vault |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The tenant ID of the Key Vault |
<!-- END_TF_DOCS -->