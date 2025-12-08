terraform {
  required_version = ">= 1.11.4, <2.0.0"

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"  
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"  
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = var.subscription_id
  client_id                       = var.client_id
}
