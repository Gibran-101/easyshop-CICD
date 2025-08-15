#Hel release name for management and trobuleshooting
#Useful for kubectl operations and Helm commands
output "release_name" {
  description = "Helm release name"
  value       = helm_release.argocd_image_updater.name
}

# Namespace where Image Updater is deployed
# Same as ArgoCD namespace, useful for kubectl commands
output "namespace" {
  description = "Namespace where ArgoCD Image Updater is deployed"
  value       = var.argocd_namespace
}

