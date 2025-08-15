# ArgoCD Image Updater Module

## Overview
Deploys ArgoCD Image Updater, which automatically monitors container registries for new image versions and updates Git repositories to maintain the GitOps workflow. This enables fully automated continuous delivery from code push to production deployment.

## Purpose
- Monitors Azure Container Registry for new image tags
- Automatically updates Kubernetes manifests in Git with new image versions
- Maintains GitOps workflow without manual intervention
- Supports various update strategies (semantic versioning, latest, etc.)
- Enables true continuous delivery with Git as single source of truth

## When to Use
Use this module when you need:
- Automated image tag updates in Git repositories
- Continuous delivery without manual manifest updates
- Integration between CI/CD pipelines and GitOps workflows
- Automatic deployment of new application versions
- Semantic versioning-based deployments

## Dependencies
- **ArgoCD module** - Must be installed first, Image Updater extends ArgoCD
- **ACR module** - Provides registry credentials and endpoints
- **AKS module** - Provides Kubernetes cluster (via ArgoCD dependency)

## What Depends on This Module
- **Nothing directly** - This is a leaf module that enhances ArgoCD functionality

## Example Usage

### Basic Setup (Public Repository)
```hcl
module "argocd_image_updater" {
  source             = "./modules/argocd-image-updater"
  kube_config        = module.aks.kube_config
  argocd_namespace   = "argocd"
  acr_login_server   = module.acr.acr_login_server
  acr_admin_username = module.acr.admin_username
  acr_admin_password = module.acr.admin_password
  github_repo_url    = "https://github.com/username/repo.git"
  
  # Public repository - no auth required
  git_require_auth = false
  
  # Semantic versioning strategy
  default_update_strategy = "semver"
  
  tags = var.tags
}
```

### Private Repository Setup (SSH)
```hcl
module "argocd_image_updater" {
  source             = "./modules/argocd-image-updater"
  kube_config        = module.aks.kube_config
  argocd_namespace   = "argocd"
  acr_login_server   = module.acr.acr_login_server
  acr_admin_username = module.acr.admin_username
  acr_admin_password = module.acr.admin_password
  github_repo_url    = "git@github.com:username/repo.git"
  
  # Private repository with SSH key
  git_require_auth     = true
  git_ssh_private_key  = var.git_ssh_private_key
  
  # Custom commit settings
  git_commit_user  = "DevOps Bot"
  git_commit_email = "devops@company.com"
  
  tags = var.tags
}
```

## How It Works
```
1. CI/CD Pipeline → Builds new image → Pushes to ACR with version tag
                                         ↓
2. Image Updater → Monitors ACR → Detects new tag → Updates Git manifest
                                         ↓
3. ArgoCD → Detects Git change → Syncs to cluster → Application updates
```

## Update Strategies

### Semantic Versioning (Recommended)
```yaml
# In your ArgoCD Application
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: app=myacr.azurecr.io/myapp:~1.0
    argocd-image-updater.argoproj.io/app.update-strategy: semver
```
- Automatically updates to newer versions within constraints
- `~1.0` = Updates 1.0.x but not 2.0.x
- `^1.0` = Updates 1.x.x but not 2.x.x

### Latest Tag
```yaml
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: app=myacr.azurecr.io/myapp:latest
    argocd-image-updater.argoproj.io/app.update-strategy: latest
```
- Always updates to the most recent image
- Useful for development environments

### Name-based Strategy
```yaml
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: app=myacr.azurecr.io/myapp
    argocd-image-updater.argoproj.io/app.update-strategy: name
    argocd-image-updater.argoproj.io/app.allow-tags: regexp:^v[0-9]+\.[0-9]+\.[0-9]+$
```
- Updates based on tag naming patterns
- Flexible regex-based filtering

## Git Authentication Methods

### Public Repository (No Auth)
- ✅ Simple setup, no credentials needed
- ✅ Works with GitHub, GitLab, etc.
- ❌ Repository must be public
- ❌ Anyone can see your configurations

### SSH Key Authentication
- ✅ Works with private repositories
- ✅ Secure key-based authentication
- ❌ Requires SSH key management
- ❌ More complex setup

### HTTPS Token Authentication
- ✅ Works with private repositories
- ✅ Simple token-based auth
- ❌ Requires personal access tokens
- ❌ Tokens need regular rotation

## Registry Configuration
The module automatically configures:
- **ACR endpoint** for API communication
- **Authentication credentials** via Kubernetes secrets
- **Registry monitoring** for new image detection
- **Tag filtering** based on update strategies

## Monitoring & Troubleshooting

### Check Image Updater Status
```bash
# View Image Updater logs
kubectl logs -n argocd deployment/argocd-image-updater

# Check configuration
kubectl get configmap argocd-image-updater-config -n argocd -o yaml

# View registry secrets
kubectl get secret acr-secret -n argocd -o yaml
```

### Common Issues
- **Registry authentication failures**: Check ACR credentials
- **Git write failures**: Verify repository permissions
- **No updates detected**: Check image tags and update strategy
- **SSL errors**: Verify registry and Git server certificates

### Application Annotations
Add these to your ArgoCD Application manifests:
```yaml
metadata:
  annotations:
    # Image list to monitor
    argocd-image-updater.argoproj.io/image-list: app=myacr.azurecr.io/myapp:~1.0
    
    # Update strategy
    argocd-image-updater.argoproj.io/app.update-strategy: semver
    
    # Write back to Git
    argocd-image-updater.argoproj.io/write-back-method: git
    
    # Target file to update
    argocd-image-updater.argoproj.io/write-back-target: kustomization
```

## Security Considerations
- **Registry credentials** stored as Kubernetes secrets
- **Git authentication** via SSH keys or tokens
- **Network policies** can restrict Image Updater access
- **RBAC** controls what Image Updater can modify
- **Audit logs** track all Git commits made

<!-- BEGIN_TF_DOCS -->

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd_image_updater](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_secret.acr_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acr_admin_password"></a> [acr\_admin\_password](#input\_acr\_admin\_password) | ACR admin password | `string` | n/a | yes |
| <a name="input_acr_admin_username"></a> [acr\_admin\_username](#input\_acr\_admin\_username) | ACR admin username | `string` | n/a | yes |
| <a name="input_acr_login_server"></a> [acr\_login\_server](#input\_acr\_login\_server) | ACR login server URL | `string` | n/a | yes |
| <a name="input_argocd_namespace"></a> [argocd\_namespace](#input\_argocd\_namespace) | ArgoCD namespace | `string` | `"argocd"` | no |
| <a name="input_default_update_strategy"></a> [default\_update\_strategy](#input\_default\_update\_strategy) | Default update strategy for applications | `string` | `"semver"` | no |
| <a name="input_github_repo_url"></a> [github\_repo\_url](#input\_github\_repo\_url) | GitHub repository URL | `string` | n/a | yes |
| <a name="input_kube_config"></a> [kube\_config](#input\_kube\_config) | Kubernetes configuration from AKS | `any` | n/a | yes |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level for ArgoCD Image Updater | `string` | `"info"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace where ArgoCD Image Updater is deployed |
| <a name="output_release_name"></a> [release\_name](#output\_release\_name) | Helm release name |
<!-- END_TF_DOCS -->