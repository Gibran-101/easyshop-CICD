resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "5.51.6"

  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}
