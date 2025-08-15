# ArgoCD Module

## Overview
Deploys ArgoCD, a declarative GitOps continuous delivery tool for Kubernetes. This module installs a complete ArgoCD instance with configurable features, optimized for both personal projects and team environments. ArgoCD automatically synchronizes your cluster state with Git repositories.

## Purpose
- Provides GitOps-based continuous deployment from Git repositories
- Automatically syncs Kubernetes manifests from your Git repo to cluster
- Offers web UI for monitoring application deployments and cluster state
- Enables declarative application management with Git as single source of truth
- Supports automatic rollbacks, health checks, and deployment notifications

## When to Use
Use this module when you need:
- Automated deployment from Git repositories (GitOps workflow)
- Visual dashboard for monitoring Kubernetes applications
- Declarative application lifecycle management
- Automatic synchronization between Git and cluster state
- Professional CI/CD pipeline with Git-based deployments

## Dependencies
- **AKS module** - Provides Kubernetes cluster and kubeconfig
- **Networking module** - For ingress configuration (if using ingress)
- **Cert-manager** (optional) - For SSL certificates with ingress

## What Depends on This Module
- **ArgoCD Image Updater module** - Requires ArgoCD to be installed first
- **Application manifests** - ArgoCD manages these after installation

## Example Usage

### Basic Setup (Personal Projects)
```hcl
module "argocd" {
  source           = "./modules/argocd"
  kube_config      = module.aks.kube_config
  argocd_namespace = "argocd"
  
  # Simple LoadBalancer access
  server_service_type = "LoadBalancer"
  enable_ingress      = false
  
  # Disable advanced features for simplicity
  enable_dex            = false
  enable_notifications  = false
  enable_applicationset = false
  
  tags = var.tags
}
```

### Production Setup (Ingress + SSL)
```hcl
module "argocd" {
  source           = "./modules/argocd"
  kube_config      = module.aks.kube_config
  argocd_namespace = "argocd"
  
  # Use ingress instead of LoadBalancer for cost savings
  server_service_type = "ClusterIP"
  enable_ingress      = true
  argocd_hostname     = "argocd.yourdomain.com"
  
  # Enable team features
  enable_dex           = true
  enable_notifications = true
  custom_admin_password = "your-secure-password"
  
  tags = var.tags
}
```

## ArgoCD Architecture
```
ArgoCD Components:
├── API Server (Web UI + gRPC API)
│   ├── Authentication & RBAC
│   └── Application Management
├── Repository Server
│   ├── Git Repository Polling
│   └── Manifest Generation
├── Application Controller
│   ├── Cluster State Monitoring
│   └── Sync Operations
└── Redis (Caching & Sessions)

Git Repository → ArgoCD → Kubernetes Cluster
     ↓              ↓           ↓
   Manifests → Sync Engine → Applied Resources
```

## Access Methods

### LoadBalancer (Simple)
- ✅ Direct public IP access
- ✅ No additional setup required
- ❌ Costs ~$20/month for load balancer
- ❌ No SSL by default

### Ingress (Cost-Effective)
- ✅ Uses existing ingress controller
- ✅ Free SSL with cert-manager
- ✅ Custom domain support
- ❌ Requires ingress controller setup
- ❌ More complex configuration

## Initial Access
```bash
# Get ArgoCD URL (LoadBalancer)
kubectl get svc argocd-server -n argocd

# Get admin password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

# Port forward for local access
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Login via CLI
argocd login localhost:8080 --username admin --password <password> --insecure
```

## GitOps Workflow
1. **Developer pushes code** to Git repository
2. **CI pipeline builds** Docker image and pushes to ACR
3. **ArgoCD Image Updater** (optional) updates image tags in Git
4. **ArgoCD detects changes** in Git repository
5. **ArgoCD syncs changes** to Kubernetes cluster
6. **Applications update** automatically

## Cost Optimization Features
- **Resource limits** on all components to control costs
- **Disabled unnecessary features** (Dex, notifications) for personal use
- **Configurable service type** (LoadBalancer vs ingress)
- **Optional components** can be enabled as needed

## Security Features
- **RBAC integration** with Kubernetes
- **TLS encryption** for API communications
- **Git repository access controls** via SSH keys or tokens
- **Custom admin passwords** supported
- **Namespace isolation** from application workloads

## Common ArgoCD Patterns
- **App of Apps**: ArgoCD manages its own applications
- **Environment Promotion**: Dev → Staging → Production
- **Multi-tenancy**: Separate projects and namespaces
- **Blue-Green Deployments**: Zero-downtime releases
- **Rollback Capabilities**: Git-based version control

## Troubleshooting
- **UI not accessible**: Check service type and ingress configuration
- **Sync failures**: Verify Git repository access and manifest syntax
- **High resource usage**: Tune resource limits for your workload
- **SSL issues**: Ensure cert-manager is working and DNS is configured
- **Authentication problems**: Check admin password and user permissions

<!-- BEGIN_TF_DOCS -->

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.argocd_admin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_chart_version"></a> [argocd\_chart\_version](#input\_argocd\_chart\_version) | Version of ArgoCD Helm chart to install | `string` | `"5.51.4"` | no |
| <a name="input_argocd_namespace"></a> [argocd\_namespace](#input\_argocd\_namespace) | Namespace for ArgoCD | `string` | `"argocd"` | no |
| <a name="input_kube_config"></a> [kube\_config](#input\_kube\_config) | Kubernetes configuration from AKS | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password"></a> [admin\_password](#output\_admin\_password) | ArgoCD admin password |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | ArgoCD namespace |
| <a name="output_server_url"></a> [server\_url](#output\_server\_url) | ArgoCD server URL |
<!-- END_TF_DOCS -->