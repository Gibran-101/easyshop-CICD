terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}