# Key Vault Secrets Module

## Overview
Generates and stores application-specific secrets in Azure Key Vault, creating a dedicated managed identity for secure access from AKS. This module handles database credentials, cache authentication, and service-to-service secrets while providing the necessary Azure role assignments for CSI Secret Store driver integration.

## Purpose
- Generates cryptographically secure passwords for MongoDB and Redis
- Stores all application secrets centrally in Azure Key Vault
- Creates dedicated managed identity for AKS pod authentication
- Configures proper Azure role assignments for CSI driver access
- Assembles connection strings for immediate application use
- Provides fallback Kubernetes secrets for legacy applications

## When to Use
Use this module when you need:
- Secure credential generation and storage for database services
- CSI Secret Store driver integration with AKS pods
- Centralized secret management for microservices applications
- Automated password rotation capabilities (future enhancement)
- Compliance with security best practices for credential management

## Dependencies
- **Key Vault module** - Provides the vault where secrets are stored
- **AKS module** - Provides kubelet identity for role assignments
- **Networking module** - For resource group and location context

## What Depends on This Module
- **AKS application deployments** - Use secrets via CSI driver or fallback secrets
- **Database configurations** - MongoDB StatefulSet uses generated credentials
- **Cache configurations** - Redis deployment uses generated authentication
- **SecretProviderClass** - References the managed identity client ID

## Example Usage

### Basic Setup (Default Configuration)
```hcl
module "keyvault_secrets" {
  source = "./modules/keyvault-secrets"

  project_name                   = "easyshop"
  location                       = "East US"
  resource_group_name            = module.networking.resource_group_name
  key_vault_id                   = module.app_keyvault.key_vault_id
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  subscription_id                = data.azurerm_client_config.current.subscription_id
  aks_kubelet_identity_object_id = module.aks.kubelet_identity.object_id
  aks_node_resource_group        = module.aks.node_resource_group

  tags = var.tags
}
```

### Production Setup (Custom Configuration)
```hcl
module "keyvault_secrets" {
  source = "./modules/keyvault-secrets"

  project_name                   = "myapp"
  location                       = "East US"
  resource_group_name            = module.networking.resource_group_name
  key_vault_id                   = module.app_keyvault.key_vault_id
  tenant_id                      = data.azurerm_client_config.current.tenant_id
  subscription_id                = data.azurerm_client_config.current.subscription_id
  aks_kubelet_identity_object_id = module.aks.kubelet_identity.object_id
  aks_node_resource_group        = module.aks.node_resource_group

  # Custom password requirements
  mongodb_password_length       = 64
  mongodb_password_special_chars = true
  redis_password_length         = 32

  # Custom service endpoints
  mongodb_service_host = "mongodb-primary.database.svc.cluster.local"
  redis_service_host   = "redis-master.cache.svc.cluster.local"

  # Additional application secrets
  additional_secrets = [
    {
      name  = "stripe-api-key"
      value = var.stripe_api_key
      tags  = { Service = "Payment" }
    },
    {
      name  = "jwt-signing-key"
      value = var.jwt_signing_key
      tags  = { Service = "Authentication" }
    }
  ]

  # Enable fallback for legacy applications
  create_kubernetes_secrets = true
  kubernetes_namespace      = "easyshop"

  tags = var.tags
}
```

## Secret Management Architecture
```
Key Vault Secrets Module
├── Random Generation
│   ├── MongoDB Username (12 chars, alphanumeric)
│   ├── MongoDB Password (32 chars, mixed)
│   └── Redis Password (24 chars, no special)
├── Key Vault Storage
│   ├── Individual Credentials (username, password, database)
│   ├── Connection Strings (assembled, ready-to-use)
│   └── Additional Secrets (API keys, tokens)
├── Managed Identity
│   ├── Dedicated Identity (project-keyvault-identity)
│   ├── Key Vault Access Policy (Get, List secrets)
│   └── AKS Role Assignments (Identity Operator, VM Contributor)
└── Optional Kubernetes Secrets
    └── Fallback for non-CSI applications

Integration Flow:
Terraform → Generates Secrets → Stores in Key Vault → Creates Identity
     ↓
AKS Pod → CSI Driver → Managed Identity → Key Vault → Mounts Secrets
```

## Generated Secrets

### MongoDB Secrets
- **mongodb-username**: Random alphanumeric username with prefix
- **mongodb-password**: Cryptographically secure password (32 chars)
- **mongodb-database**: Database name (configurable)
- **mongodb-connection-string**: Complete connection URI with auth

### Redis Secrets
- **redis-password**: Secure password without special chars (24 chars)
- **redis-connection-string**: Complete Redis URI with authentication

### Connection String Formats
```bash
# MongoDB
mongodb://mongouser123abc:SecurePassword123!@mongodb-0.mongodb-service.easyshop.svc.cluster.local:27017/easyshop?authSource=admin

# Redis
redis://:RedisPassword123@easyshop-redis.easyshop.svc.cluster.local:6379
```

## CSI Driver Integration

### SecretProviderClass Configuration
```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: app-secrets
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityClientID: "output-from-this-module"
    keyvaultName: "your-keyvault-name"
    tenantId: "your-tenant-id"
    objects: |
      array:
        - |
          objectName: mongodb-username
          objectType: secret
        - |
          objectName: mongodb-password
          objectType: secret
        - |
          objectName: redis-password
          objectType: secret
```

### Pod Volume Mount
```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    volumeMounts:
    - name: secrets
      mountPath: "/mnt/secrets"
      readOnly: true
  volumes:
  - name: secrets
    csi:
      driver: secrets-store.csi.x-k8s.io
      readOnly: true
      volumeAttributes:
        secretProviderClass: "app-secrets"
```

## Security Features

### Password Generation
- **Cryptographically secure** using Terraform's random provider
- **Configurable complexity** (length, character sets)
- **Immutable by default** - prevents accidental changes
- **No storage in Terraform state** - only references

### Access Control
- **Dedicated managed identity** per project/application
- **Minimal permissions** (Get, List only) for CSI driver
- **Azure role assignments** for proper identity propagation
- **No stored credentials** - all authentication via Azure AD

### Secret Organization
- **Consistent naming** conventions for easy reference
- **Content type metadata** for proper handling
- **Resource tagging** for organization and compliance
- **Secret versioning** supported through Key Vault

## Common Usage Patterns

### Application Configuration
```go
// Go application reading mounted secrets
dbPassword, err := ioutil.ReadFile("/mnt/secrets/mongodb-password")
if err != nil {
    log.Fatal(err)
}

dbConnString, err := ioutil.ReadFile("/mnt/secrets/mongodb-connection-string")
if err != nil {
    log.Fatal(err)
}
```

### Environment Variable Injection
```yaml
# Using secretObjects in SecretProviderClass
secretObjects:
- secretName: app-secrets
  type: Opaque
  data:
  - objectName: mongodb-password
    key: DB_PASSWORD
  - objectName: redis-password
    key: REDIS_PASSWORD
```

## Monitoring & Troubleshooting

### Common Issues
- **CSI driver mount failures**: Check managed identity permissions
- **Secret not found**: Verify Key Vault access policies
- **Authentication errors**: Ensure proper role assignments
- **Pod startup failures**: Check SecretProviderClass configuration

### Verification Commands
```bash
# Check managed identity
az identity show --name easyshop-keyvault-identity --resource-group easyshop-rg

# Verify Key Vault access
az keyvault secret list --vault-name easyshop-kv

# Check AKS role assignments
az role assignment list --assignee <identity-principal-id>

# Test CSI driver
kubectl describe pod <pod-name> | grep -A 20 "Volumes:"
```

### Secret Rotation
- **Manual rotation**: Delete and re-apply Terraform resources
- **Automated rotation**: Use Azure Key Vault rotation policies (future)
- **Application restart**: Required after secret rotation
- **Zero-downtime rotation**: Possible with proper application design

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_access_policy.keyvault_identity_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_secret.mongodb_database](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.mongodb_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.mongodb_uri](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.mongodb_username](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.redis_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.redis_uri](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_role_assignment.aks_identity_operator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_vmss_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.keyvault_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [random_password.mongodb_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.redis_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.mongodb_username](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_kubelet_identity_object_id"></a> [aks\_kubelet\_identity\_object\_id](#input\_aks\_kubelet\_identity\_object\_id) | Object ID of the AKS kubelet managed identity | `string` | n/a | yes |
| <a name="input_aks_node_resource_group"></a> [aks\_node\_resource\_group](#input\_aks\_node\_resource\_group) | AKS node resource group name | `string` | n/a | yes |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | ID of the Key Vault to store secrets in | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Azure AD tenant ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_managed_identity_client_id"></a> [managed\_identity\_client\_id](#output\_managed\_identity\_client\_id) | Client ID of the managed identity for Key Vault access |
| <a name="output_managed_identity_id"></a> [managed\_identity\_id](#output\_managed\_identity\_id) | Full resource ID of the managed identity |
| <a name="output_managed_identity_principal_id"></a> [managed\_identity\_principal\_id](#output\_managed\_identity\_principal\_id) | Principal ID of the managed identity |
| <a name="output_secrets_stored"></a> [secrets\_stored](#output\_secrets\_stored) | List of secrets stored in Key Vault |
<!-- END_TF_DOCS -->