# Create namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.4"  # Latest stable version
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  
  # Basic configuration for personal project
  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"  # Expose ArgoCD UI
        }
      }
      # Disable components not needed for personal project
      dex = {
        enabled = false  # Disable SSO
      }
      notifications = {
        enabled = false  # Disable notifications controller
      }
      applicationSet = {
        enabled = false  # Disable ApplicationSet controller
      }
    })
  ]
  
  depends_on = [kubernetes_namespace.argocd]
}

# Get ArgoCD initial admin password
data "kubernetes_secret" "argocd_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  
  depends_on = [helm_release.argocd]
}