output "release_name" {
  description = "Helm release name"
  value       = helm_release.argocd_image_updater.name
}