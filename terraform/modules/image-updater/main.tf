resource "helm_release" "image_updater" {
  name       = "argocd-image-updater"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"
  version    = "0.9.2"

  values = [
    templatefile("${path.module}/values.yml.tpl", {
      acr_name         = var.acr_name,
      acr_username     = var.acr_username,
      acr_password     = var.acr_password,
      acr_login_server = var.acr_login_server,
      github_owner     = var.github_owner,
      github_repo      = var.github_repo,
      github_username  = var.github_username,
      github_token     = var.github_token,
      github_url       = "https://github.com/${var.github_owner}/${var.github_repo}",
    })
  ]
}
