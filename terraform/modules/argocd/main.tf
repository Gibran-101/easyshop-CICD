# Dedicated namespace for ArgoCD components - isolates GitOps infrastructure
# Separates ArgoCD from application workloads for better organization and security
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

# ArgoCD installation using official Helm chart
# Provides complete GitOps platform for continuous deployment from Git repositories
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Basic configuration for personal project
  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer" # Expose ArgoCD UI
        }
      }
      notifications = {
        enabled = false # Disable notifications controller
      }
      applicationSet = {
        enabled = false # Disable ApplicationSet controller
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# Retrieve the auto-generated admin password for initial access
# ArgoCD creates this secret during installation with a random password
data "kubernetes_secret" "argocd_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  depends_on = [helm_release.argocd]
}