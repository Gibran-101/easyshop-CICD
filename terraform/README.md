# EasyShop Infrastructure - Complete Azure DevOps Platform

> **A production-ready, cloud-native e-commerce platform built with modern DevOps practices, Infrastructure as Code, and GitOps workflows.**

## 🏗️ **Project Overview**

EasyShop is a comprehensive infrastructure project that demonstrates enterprise-grade DevOps practices using Azure cloud services, Kubernetes, and automated CI/CD pipelines. This project creates a complete, scalable, and secure platform for hosting modern web applications with full observability and GitOps deployment workflows.

### **What This Project Provides**
- **Complete Azure Infrastructure** - Network, security, compute, and storage
- **Kubernetes Platform** - Production-ready AKS cluster with ingress and load balancing
- **GitOps Deployment** - ArgoCD for automated application lifecycle management
- **Container Registry** - Private Docker registry with automated image updates
- **Secret Management** - Azure Key Vault integration with CSI Secret Store driver
- **DNS Management** - Professional domain hosting with Azure DNS
- **Infrastructure as Code** - 100% Terraform-managed infrastructure
- **CI/CD Pipelines** - GitHub Actions for automated testing and deployment

### **Technology Stack**
| Component | Technology | Purpose |
|-----------|------------|---------|
| **Cloud Provider** | Microsoft Azure | Infrastructure hosting and managed services |
| **Container Orchestration** | Azure Kubernetes Service (AKS) | Application runtime and scaling |
| **Infrastructure as Code** | Terraform | Declarative infrastructure provisioning |
| **GitOps** | ArgoCD + Image Updater | Continuous deployment and sync |
| **Container Registry** | Azure Container Registry | Private image storage |
| **Secret Management** | Azure Key Vault + CSI Driver | Secure credential storage |
| **DNS** | Azure DNS | Domain resolution and routing |
| **Load Balancing** | NGINX Ingress Controller | Traffic routing and SSL termination |
| **CI/CD** | GitHub Actions | Automated testing and deployment |

## 🧩 **Module Architecture Deep Dive**

The root module orchestrates eight specialized modules, each with distinct responsibilities. Here's how they integrate and depend on each other:

### **Layer 1: Foundation (No Dependencies)**

#### **Networking Module** - `./modules/networking`
The cornerstone module that establishes the network foundation for all other components.

**Creates**: Resource group, Virtual Network (10.0.0.0/16), AKS subnet (10.0.1.0/24), Network Security Groups
**Root Module Integration**: Called first to provide `resource_group_name`, `aks_subnet_id`, and `location` to all subsequent modules
**Critical Outputs**: Every other module depends on `resource_group_name` for resource placement
**Security**: Configured with HTTP/HTTPS ingress rules and service endpoints for secure Azure service access

### **Layer 2: Security & Storage (Depends on Networking)**

#### **Key Vault Module** - `./modules/vault`  
Establishes centralized secret management with enterprise-grade security controls.

**Creates**: Azure Key Vault instance, admin access policies, optional network restrictions, audit logging
**Root Module Integration**: Uses `module.networking.resource_group_name` for placement, receives admin identity from `data.azurerm_client_config.current.object_id`
**Network Integration**: Can restrict access to the AKS subnet using `module.networking.aks_subnet_id`
**Security Features**: Purge protection enabled, 90-day soft delete retention, Azure AD integration

#### **Container Registry Module** - `./modules/acr`
Private Docker registry for secure image storage and distribution.

**Creates**: Azure Container Registry with admin credentials, retention policies, and security scanning
**Root Module Integration**: Placed in `module.networking.resource_group_name`, credentials automatically stored in Key Vault
**Image Management**: Configured with automatic cleanup policies to control storage costs
**CI/CD Integration**: Admin credentials are stored in Key Vault via the root module for GitHub Actions access

### **Layer 3: Compute Platform (Depends on Networking, Security, Storage)**

#### **AKS Module** - `./modules/aks`
The heart of the platform - a production-ready Kubernetes cluster with Azure integrations.

**Creates**: AKS cluster, system node pool, kubelet managed identity, role assignments
**Root Module Integration**: 
- **Network**: Deploys into `module.networking.aks_subnet_id`
- **Registry**: Gets automatic image pull access via `module.acr.acr_id` 
- **Security**: Kubelet identity receives Key Vault access for CSI driver
**Cluster Configuration**: Uses variables from root module (`aks_node_count`, `aks_vm_size`, `aks_enable_auto_scaling`)
**Critical Output**: Provides `kube_config` that enables Kubernetes and Helm providers in root module

### **Layer 4: Application Services (Depends on AKS, Key Vault)**

#### **Key Vault Secrets Module** - `./modules/keyvault-secrets`
Generates application credentials and configures secure access patterns.

**Creates**: Dedicated managed identity, MongoDB/Redis credentials, AKS role assignments
**Root Module Integration**:
- **Secret Storage**: Uses `module.app_keyvault.key_vault_id` to store generated secrets
- **AKS Integration**: Uses `module.aks.kubelet_identity.object_id` and `module.aks.node_resource_group` for role assignments
- **Identity Configuration**: Receives `tenant_id` and `subscription_id` from data sources
**CSI Driver Setup**: Creates all necessary role assignments for pods to mount secrets as files
**Critical Output**: `managed_identity_client_id` used in Kubernetes SecretProviderClass configurations

### **Layer 5: Network Services (Depends on Networking, AKS)**

#### **DNS Module** - `./modules/dns`
Professional domain management with Azure's global DNS infrastructure.

**Creates**: DNS zone, A records, optional subdomain management, nameserver configuration
**Root Module Integration**: 
- **Network**: Uses `module.networking.resource_group_name` for placement
- **Traffic**: Points A record to `azurerm_public_ip.ingress_ip.id` (created in root module)
**Domain Configuration**: Manages the domain specified in `var.dns_zone_name`
**Critical Output**: `name_servers` that must be configured at domain registrar

### **Layer 6: Platform Services (Depends on AKS)**

#### **Traefik Ingress Controller** - Root Module Resource
Modern reverse proxy and load balancer with automatic HTTPS capabilities.

**Creates**: Traefik deployment via Helm, service with static IP binding, dashboard access
**Integration**: 
- **Cluster**: Deployed on `module.aks` cluster using kubeconfig
- **Network**: Binds to `azurerm_public_ip.ingress_ip` created in root module
- **DNS**: Works with DNS module to provide HTTPS termination for domains
**Traffic Flow**: All external traffic flows through Traefik to reach applications

#### **ArgoCD Module** - `./modules/argocd`
GitOps platform for declarative application lifecycle management.

**Creates**: ArgoCD installation, admin credentials, dashboard access, Git repository integration
**Root Module Integration**: 
- **Cluster**: Deployed on AKS using `module.aks.kube_config`
- **Namespace**: Uses `var.argocd_namespace` for deployment isolation
**GitOps Workflow**: Monitors `var.github_repo_url` for application manifest changes
**Critical Output**: Provides admin credentials for accessing GitOps dashboard

### **Layer 7: Automation (Depends on ArgoCD, ACR)**

#### **ArgoCD Image Updater Module** - `./modules/argocd-image-updater`
Automated image update system for complete CI/CD automation.

**Creates**: Image Updater deployment, ACR monitoring configuration, Git write-back setup
**Root Module Integration**:
- **Platform**: Extends `module.argocd` with automated update capabilities
- **Registry**: Monitors `module.acr.acr_login_server` for new image tags
- **Authentication**: Uses `module.acr.admin_username` and `module.acr.admin_password` for registry access
- **Git Integration**: Configured to update `var.github_repo_url` with new image versions
**Automation Flow**: Creates complete CI/CD pipeline from code push to production deployment

## 🔄 **Integration Workflows**

### **Infrastructure Deployment Sequence**
```
1. Networking (Foundation)
   ↓
2. Key Vault + ACR (Security & Storage) 
   ↓
3. AKS (Compute Platform)
   ↓
4. Static IP + Traefik (Network Services)
   ↓  
5. DNS + ArgoCD (Platform Services)
   ↓
6. Key Vault Secrets + Image Updater (Application Services)
```

### **Application Deployment Workflow**
```
Developer Code Push
   ↓
GitHub Actions (Build & Push to ACR)
   ↓
ArgoCD Image Updater (Detects new image)
   ↓
Git Manifest Update (Automated commit)
   ↓
ArgoCD Sync (Deploy to AKS)
   ↓
CSI Driver (Mount secrets from Key Vault)
   ↓
Traefik (Route traffic to application)
   ↓
DNS Resolution (Users access via domain)
```

### **Secret Management Flow**
```
Terraform Deploy
   ↓
Key Vault Secrets Module (Generate credentials)
   ↓
Store in Key Vault (Encrypted storage)
   ↓
Create Managed Identity (AKS access)
   ↓
Pod Startup (CSI driver activation)
   ↓
Secret Mount (Files appear in container)
   ↓
Application Access (Read secrets from filesystem)
```

## 🚀 **Getting Started**

### **Prerequisites**
- Azure subscription with Contributor/Owner role
- Domain name with nameserver configuration access
- GitHub repository for GitOps workflow
- Local tools: Terraform (≥1.6), Azure CLI, kubectl, Git

### **Quick Deployment**
```bash
# 1. Clone and configure
git clone <your-repo-url>
cd EasyShop-KIND/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration

# 2. Authenticate and deploy
az login
terraform init
terraform plan
terraform apply

# 3. Configure DNS (use output nameservers)
terraform output dns_nameservers

# 4. Access platform
az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw aks_cluster_name)
kubectl get pods --all-namespaces
```

### **Post-Deployment Configuration**
1. **DNS Setup**: Configure nameservers at domain registrar using `terraform output dns_nameservers`
2. **ArgoCD Access**: Get admin password with `kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d`
3. **Application Deployment**: Deploy applications via ArgoCD or direct kubectl
4. **Monitoring Setup**: Configure observability stack in the `monitoring` namespace

## 📊 **Operational Excellence**

### **Cost Management**
- **Estimated Monthly Cost**: $80-120 (optimized for personal projects)
- **Cost Drivers**: AKS nodes (60%), Load Balancer (25%), Storage/Network (15%)
- **Optimization**: B-series VMs, single-node start, auto-scaling enabled

### **Security Features**
- **Zero-Trust Architecture**: All services require authentication
- **Secret Management**: No secrets in Git, encrypted at rest and in transit
- **Network Security**: Private subnets, NSGs, service endpoints
- **Identity Management**: Managed identities, no stored credentials

### **Monitoring & Observability**
- **Built-in**: AKS Insights, Key Vault audit logs, DNS analytics
- **Platform Ready**: Pre-configured for Prometheus/Grafana stack
- **Application Metrics**: Traefik dashboard, ArgoCD sync status

## 🎯 **Production Readiness**

This infrastructure is designed for production workloads with:
- **High Availability**: Multi-zone deployment options, redundant components
- **Disaster Recovery**: Backup strategies, infrastructure as code recovery
- **Compliance**: Audit logging, encryption, access controls
- **Scalability**: Auto-scaling, load balancing, horizontal pod scaling
- **Maintainability**: Modular design, GitOps workflows, automated updates

## 🤝 **Contributing**

This project welcomes contributions! Whether you're learning DevOps or are an experienced platform engineer, there are opportunities to:
- Enhance module functionality
- Improve documentation
- Add monitoring components
- Optimize costs and performance
- Strengthen security posture

---

**Author**: [iemafzalhassan](https://github.com/iemafzalhassan)  
**Project**: EasyShop Infrastructure Platform  
**License**: MIT  

<!-- BEGIN_TF_DOCS -->
## Terraform Documentation

### Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acr_name"></a> [acr\_name](#input\_acr\_name) | Azure Container Registry name (must be globally unique) | `string` | n/a | yes |
| <a name="input_admin_object_id"></a> [admin\_object\_id](#input\_admin\_object\_id) | Azure AD Object ID of additional admin user/service principal (optional) | `string` | `""` | no |
| <a name="input_aks_cluster_name"></a> [aks\_cluster\_name](#input\_aks\_cluster\_name) | AKS cluster name | `string` | n/a | yes |
| <a name="input_aks_enable_auto_scaling"></a> [aks\_enable\_auto\_scaling](#input\_aks\_enable\_auto\_scaling) | Enable AKS auto-scaling | `bool` | `false` | no |
| <a name="input_aks_node_count"></a> [aks\_node\_count](#input\_aks\_node\_count) | Number of AKS nodes | `number` | `1` | no |
| <a name="input_aks_vm_size"></a> [aks\_vm\_size](#input\_aks\_vm\_size) | Size of AKS node VMs | `string` | `"Standard_B2s"` | no |
| <a name="input_argocd_namespace"></a> [argocd\_namespace](#input\_argocd\_namespace) | Kubernetes namespace for ArgoCD | `string` | `"argocd"` | no |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | Azure DNS zone name | `string` | n/a | yes |
| <a name="input_github_repo_url"></a> [github\_repo\_url](#input\_github\_repo\_url) | GitHub repository URL for ArgoCD | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region to deploy resources | `string` | `"East US"` | no |
| <a name="input_observability_namespace"></a> [observability\_namespace](#input\_observability\_namespace) | Kubernetes namespace for observability stack | `string` | `"monitoring"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group name (if using existing) | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br>  "ManagedBy": "Terraform",<br>  "Project": "EasyShop"<br>}</pre> | no |

### Outputs
| Name | Description |
|------|-------------|
| <a name="output_acr_login_server"></a> [acr\_login\_server](#output\_acr\_login\_server) | ACR login server URL |
| <a name="output_application_url"></a> [application\_url](#output\_application\_url) | Primary application URL |
| <a name="output_argocd_url"></a> [argocd\_url](#output\_argocd\_url) | ArgoCD dashboard URL (use kubectl port-forward if not exposed) |
| <a name="output_dns_nameservers"></a> [dns\_nameservers](#output\_dns\_nameservers) | Nameservers to configure at your domain registrar |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | Application Key Vault name |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | Application Key Vault URI |
| <a name="output_managed_identity_client_id"></a> [managed\_identity\_client\_id](#output\_managed\_identity\_client\_id) | Client ID of the managed identity for Key Vault access |
| <a name="output_next_steps"></a> [next\_steps](#output\_next\_steps) | Next steps after infrastructure deployment |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name |
| <a name="output_secrets_stored"></a> [secrets\_stored](#output\_secrets\_stored) | List of secrets stored in Key Vault |
| <a name="output_static_ip_address"></a> [static\_ip\_address](#output\_static\_ip\_address) | The static IP address |
| <a name="output_static_ip_fqdn"></a> [static\_ip\_fqdn](#output\_static\_ip\_fqdn) | The Azure FQDN |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | Azure AD tenant ID |
| <a name="output_useful_commands"></a> [useful\_commands](#output\_useful\_commands) | Useful commands for managing the infrastructure |
<!-- END_TF_DOCS -->