# modules/image-updater/values.yaml.tpl
config:
  registries:
    - name: acr
      api_url: https://${acr_name}.azurecr.io
      prefix: ${acr_name}.azurecr.io
      credentials:
        username: ${acr_username}
        password: ${acr_password}

  git:
    credentials:
      - url: ${github_url}
        username: ${github_username}
        password: ${github_token}
