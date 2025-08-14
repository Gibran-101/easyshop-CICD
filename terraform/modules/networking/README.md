# Networking Module

## Overview
Creates the foundational networking infrastructure for the EasyShop project. This module establishes a secure, isolated network environment with proper subnet segmentation and service endpoints for Azure service integration.

## Purpose
- Provides a dedicated resource group for all project resources
- Creates an isolated virtual network with appropriate IP address space
- Sets up a subnet specifically designed for AKS workloads
- Configures network security rules for web traffic
- Enables direct, secure connectivity to Azure services via service endpoints

## When to Use
Use this module as the foundation layer for any Azure Kubernetes Service deployment that requires:
- Isolated networking with custom IP ranges
- Direct access to Azure services (Key Vault, ACR, Storage)
- Basic web traffic security controls
- Centralized resource management

## Dependencies
- Azure Provider configured
- Valid Azure subscription and region

## Example Usage
```hcl
module "networking" {
  source       = "./modules/networking"
  project_name = "easyshop"
  location     = "East US"
  tags = {
    Project   = "EasyShop"
    ManagedBy = "Terraform"
  }
}
```

## Network Architecture
```
Virtual Network (10.0.0.0/16)
├── AKS Subnet (10.0.1.0/24)
│   ├── Service Endpoints → Key Vault, ACR, Storage
│   └── NSG → HTTP/HTTPS traffic allowed
└── Future subnets can use 10.0.2.0/24, 10.0.3.0/24, etc.
```

## Security Considerations
- NSG allows public HTTP/HTTPS traffic (required for web applications)
- Service endpoints provide secure, direct Azure service access
- Subnet is isolated from other potential network segments

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
| [azurerm_network_security_group.aks_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.aks_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_nsg_id"></a> [aks\_nsg\_id](#output\_aks\_nsg\_id) | The ID of the AKS Network Security Group |
| <a name="output_aks_subnet_id"></a> [aks\_subnet\_id](#output\_aks\_subnet\_id) | The ID of the AKS subnet |
| <a name="output_location"></a> [location](#output\_location) | The location of the resource group |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The ID of the resource group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The ID of the virtual network |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | The name of the virtual network |
<!-- END_TF_DOCS -->