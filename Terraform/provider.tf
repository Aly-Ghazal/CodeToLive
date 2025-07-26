terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.37.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  # You can specify subscription_id, client_id, client_secret, tenant_id here
  # if not using Azure CLI authentication (az login) "which we will use".
  subscription_id = "7b61b70e-5c14-48ed-a360-fec1229a16a8"
}