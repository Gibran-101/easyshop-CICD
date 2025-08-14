# AKS Module

## Overview
Creates a production-ready Azure Kubernetes Service (AKS) cluster with proper security, networking, and cost optimization. This module handles the core Kubernetes infrastructure needed to run containerized applications with automatic Azure service integration.

## Purpose
- Deploys a managed Kubernetes cluster with Azure CNI networking
- Configures secure access to Azure Container Registry for image pulls
- Sets up Key Vault integration for secret management via CSI drivers
- Implements RBAC and network policies for security
- Optimizes for cost while maintaining production capabilities

## When to Use
Use this module when you need:
- A managed Kubernetes cluster in Azure
- Automatic integration with ACR and Key Vault
- Network policies and security controls
- Cost-optimized node pools with auto-scaling options
- Professional-grade container orchestration

## Dependencies
- Networking module (for subnet and VNet)
- ACR module (for container registry)
- Key Vault module (optional, for secrets)

## Example Usage
```hcl
module "aks" {
  source              = "./modules/aks"
  aks_cluster_name    = "myproject-aks"
  resource_group_name = module.networking.resource_group_name
  location            = "East US"
  vnet_subnet_id      = module.networking.aks_subnet_id
  acr_id              = module.acr.acr_id
  key_vault_id        = module.keyvault.key_vault_id
  
  # Cost-optimized settings
  node_count          = 1
  vm_size             = "Standard_B2s"
  enable_auto_scaling = false
  kubernetes_version  = "1.28.3"
  
  tags = {
    Project = "MyProject"
    Owner   = "DevTeam"
  }
}
```

## Architecture
```
AKS Cluster
├── System Node Pool (managed by Azure)
│   └── System pods (CoreDNS, kube-proxy, etc.)
├── Default Node Pool (your configuration)
│   ├── Application pods
│   └── Auto-scaling (optional)
├── Network Profile
│   ├── Azure CNI (pod networking)
│   ├── Network policies (pod security)
│   └── Load balancer (Standard SKU)
└── Integrations
    ├── ACR (image pulls)
    ├── Key Vault (secrets via CSI)
    └── Azure Monitor (optional)
```

## Cost Optimization Features
- **B-series VMs** for cost-effective compute
- **Managed disks** instead of premium storage
- **Auto-scaling** to match workload demands
- **Optional monitoring** to control logging costs
- **Single node pool** to start simple

## Security Features
- **System-assigned managed identity** (no stored credentials)
- **RBAC enabled** for granular access control
- **Network policies** for pod-to-pod security
- **Private subnet deployment** via VNet integration
- **Automatic ACR authentication** via role assignment

## Node Pool Sizing Guide
| VM Size | vCPUs | RAM | Use Case | Monthly Cost* |
|---------|-------|-----|----------|---------------|
| Standard_B2s | 2 | 4GB | Development/Testing | ~$30 |
| Standard_D2s_v3 | 2 | 8GB | Small Production | ~$70 |
| Standard_D4s_v3 | 4 | 16GB | Medium Production | ~$140 |

*Approximate costs for East US region, single node

## Monitoring & Troubleshooting
- Use `kubectl` with downloaded kubeconfig
- Monitor costs in Azure portal under resource group
- Check AKS insights for cluster health (if monitoring enabled)
- Review NSG rules if connectivity issues occur

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_role_assignment.aks_acr_pull](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_keyvault_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acr_id"></a> [acr\_id](#input\_acr\_id) | ID of the Azure Container Registry | `string` | n/a | yes |
| <a name="input_admin_group_object_ids"></a> [admin\_group\_object\_ids](#input\_admin\_group\_object\_ids) | Azure AD group object IDs for cluster admin access | `list(string)` | `[]` | no |
| <a name="input_aks_cluster_name"></a> [aks\_cluster\_name](#input\_aks\_cluster\_name) | Name of the AKS cluster | `string` | n/a | yes |
| <a name="input_enable_auto_scaling"></a> [enable\_auto\_scaling](#input\_enable\_auto\_scaling) | Enable auto-scaling for the default node pool | `bool` | `false` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | ID of the Key Vault (optional) | `string` | `""` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version to use | `string` | `"1.30.0"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the AKS cluster | `string` | n/a | yes |
| <a name="input_max_count"></a> [max\_count](#input\_max\_count) | Maximum number of nodes when auto-scaling is enabled | `number` | `3` | no |
| <a name="input_min_count"></a> [min\_count](#input\_min\_count) | Minimum number of nodes when auto-scaling is enabled | `number` | `2` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Number of nodes in the default node pool | `number` | `2` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Size of the VMs in the default node pool | `string` | `"Standard_D2_v2"` | no |
| <a name="input_vnet_subnet_id"></a> [vnet\_subnet\_id](#input\_vnet\_subnet\_id) | ID of the subnet where AKS nodes will be deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_fqdn"></a> [cluster\_fqdn](#output\_cluster\_fqdn) | The FQDN of the AKS cluster |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID of the AKS cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the AKS cluster |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | Kubernetes config for connecting to the cluster |
| <a name="output_kube_config_raw"></a> [kube\_config\_raw](#output\_kube\_config\_raw) | Raw Kubernetes config for connecting to the cluster |
| <a name="output_kubelet_identity"></a> [kubelet\_identity](#output\_kubelet\_identity) | The managed identity of the kubelet |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | The auto-generated resource group for AKS nodes |
<!-- END_TF_DOCS -->