# Deploy ArgoCD Image Updater via Helm to auto-update image tags in Git repos
resource "helm_release" "argocd_image_updater" {
  name       = "argocd-image-updater"                 # Helm release name
  repository = "https://argoproj.github.io/argo-helm" # Official Argo Helm repo
  chart      = "argocd-image-updater"                 # Chart name
  version    = "0.9.1"                                # Chart version
  namespace  = var.argocd_namespace                   # Deploy in ArgoCD namespace

  # Logging verbosity level
  set {
    name  = "config.logLevel"
    value = var.log_level
  }

  # Update policy: semver range within 1.x.x versions
  set {
    name = "config.applications.defaultUpdateStrategy"
    # value = "semver:~1.0"
    value = var.default_update_strategy
  }

  # Registry name for internal reference
  set {
    name  = "config.registries[0].name"
    value = "acr"
  }

  # ACR API endpoint
  set {
    name  = "config.registries[0].api_url"
    value = "https://${var.acr_login_server}"
  }

  # Prefix to match ACR images
  set {
    name  = "config.registries[0].prefix"
    value = var.acr_login_server
  }

  # Use pull secret for ACR auth
  set {
    name  = "config.registries[0].credentials"
    value = "pullsecret:${var.argocd_namespace}/acr-secret"
  }
}

# Kubernetes secret for ACR authentication
resource "kubernetes_secret" "acr_secret" {
  metadata {
    name      = "acr-secret"         # Secret name
    namespace = var.argocd_namespace # Same namespace as ArgoCD
  }

  type = "kubernetes.io/dockerconfigjson" # Docker auth secret type

  # Encoded Docker config for ACR
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.acr_login_server}" = {
          username = var.acr_admin_username
          password = var.acr_admin_password
          auth     = base64encode("${var.acr_admin_username}:${var.acr_admin_password}")
        }
      }
    })
  }
}
