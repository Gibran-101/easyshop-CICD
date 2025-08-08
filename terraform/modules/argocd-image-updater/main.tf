resource "helm_release" "argocd_image_updater" {
  name       = "argocd-image-updater"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"
  version    = "0.9.1"  # Latest stable version
  namespace  = var.argocd_namespace
  
  # Configure ACR access
  set {
    name  = "config.registries[0].name"
    value = "acr"
  }
  
  set {
    name  = "config.registries[0].api_url"
    value = "https://${var.acr_login_server}"
  }
  
  set {
    name  = "config.registries[0].prefix"
    value = var.acr_login_server
  }
  
  set {
    name  = "config.registries[0].credentials"
    value = "pullsecret:${var.argocd_namespace}/acr-secret"
  }
  
  # Configure GitHub for write-back
  set {
    name  = "config.git.requireAuth"
    value = "false"  # Set to true if your repo is private
  }
}

# Create ACR pull secret for Image Updater
resource "kubernetes_secret" "acr_secret" {
  metadata {
    name      = "acr-secret"
    namespace = var.argocd_namespace
  }
  
  type = "kubernetes.io/dockerconfigjson"
  
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