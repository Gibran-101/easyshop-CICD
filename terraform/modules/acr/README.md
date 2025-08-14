# ACR Module

## Overview
Creates an Azure Container Registry (ACR) for storing and managing private Docker container images. This module provides a secure, private registry with automatic cleanup policies and flexible access controls suitable for both development and production workloads.

## Purpose
- Provides private Docker image storage for your applications
- Enables automatic image cleanup to control storage costs
- Integrates seamlessly with AKS for image pulls
- Supports various security and access control configurations

## When to Use
Use this module when you need:
- Private container image storage (alternative to Docker Hub)
- Secure image distribution to AKS clusters
- Automatic cleanup of old/unused images
- Integration with CI/CD pipelines for image building
- Cost-effective container registry with configurable features

## Dependencies
- Resource group (typically from networking module)
- No other direct dependencies

## What Depends on This Module
- **AKS module** - Needs ACR ID for role assignment (image pull permissions)
- **ArgoCD Image Updater module** - Requires ACR login server and admin credentials
- **CI/CD pipelines** - Use ACR for pushing built images
- **Key Vault module** - Stores ACR credentials as secrets (in main.tf)

## Example Usage

### Basic Setup (Personal Projects)
```hcl
module "acr" {
  source              = "./modules/acr"
  acr_name            = "myprojectacr2024"
  resource_group_name = module.networking.resource_group_name
  location            = "East US"
  
  # Cost-optimized settings
  sku                    = "Basic"
  admin_enabled          = true
  enable_retention_policy = true
  retention_days         = 7
  
  tags = {
    Project = "MyProject"
    Owner   = "DevTeam"
  }
}
```

## SKU Comparison

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| **Monthly Cost** | ~$5 | ~$20 | ~$50+ |
| **Storage Included** | 10 GB | 100 GB | 500 GB |
| **Webhooks** | ❌ | ✅ | ✅ |
| **Geo-replication** | ❌ | ❌ | ✅ |
| **Content Trust** | ❌ | ❌ | ✅ |
| **Private Link** | ❌ | ❌ | ✅ |
| **VNet Integration** | ❌ | ❌ | ✅ |
| **Image Scanning** | ❌ | ❌ | ✅ |

## Container Image Workflow
```
Developer → Docker Build → Push to ACR → AKS Pulls Image → Pod Runs
    ↓
CI/CD Pipeline → Automated Build → Push to ACR → ArgoCD Deploys
```

## Cost Optimization Features
- **Retention Policy**: Automatically deletes old images to prevent storage bloat
- **Basic SKU**: Perfect for personal projects and small teams
- **Admin Authentication**: Simple setup without complex identity management
- **Regional Storage**: Single region deployment keeps costs low

## Security Features
- **Private Registry**: Images not accessible from public internet
- **Admin Controls**: Optional admin user for simple authentication
- **Network Rules**: Control which IPs/VNets can access registry
- **Content Trust**: Digital signatures for image verification (Premium)
- **Quarantine Policy**: Hold images until security scans pass (Premium)

## Integration with AKS
- AKS automatically gets pull permissions via managed identity
- No manual authentication configuration required
- Images pulled directly within Azure network (fast and secure)
- Supports both public and private images

## Common Commands
```bash
# Login to registry
az acr login --name myprojectacr2024

# Build and push image
docker build -t myprojectacr2024.azurecr.io/myapp:v1.0 .
docker push myprojectacr2024.azurecr.io/myapp:v1.0

# List repositories
az acr repository list --name myprojectacr2024

# View retention policy
az acr config retention show --registry myprojectacr2024
```

## Troubleshooting
- **Push failures**: Check admin credentials or Azure login status
- **Pull failures from AKS**: Verify role assignment in AKS module
- **Storage costs growing**: Enable retention policy to auto-cleanup old images
- **Access denied**: Check network rules if using restrictive access controls

<!-- BEGIN_TF_DOCS -->

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acr_name"></a> [acr\_name](#input\_acr\_name) | Name of the Azure Container Registry (must be globally unique) | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the ACR | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the ACR | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acr_id"></a> [acr\_id](#output\_acr\_id) | The ID of the container registry |
| <a name="output_acr_login_server"></a> [acr\_login\_server](#output\_acr\_login\_server) | The login server URL for the container registry |
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | The admin password for the container registry |
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | The admin username for the container registry |
<!-- END_TF_DOCS -->