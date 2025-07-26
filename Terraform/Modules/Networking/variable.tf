# Define variables for resource naming and location
variable "resource_group_name" {
  description = "The name of the resource group to create."
  type        = string
  default     = "aks-secure-rg"
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
  default     = "East US" # You can change this to your preferred region
}

variable "vnet_name" {
  description = "The name of the Virtual Network."
  type        = string
  default     = "aks-secure-vnet"
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_name" {
  description = "The name of the AKS subnet."
  type        = string
  default     = "aks-subnet"
}

variable "aks_subnet_address_prefix" {
  description = "The address prefix for the AKS subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "runner_subnet_name" {
  description = "The name of the GitHub Actions Runner VM subnet."
  type        = string
  default     = "runner-subnet"
}

variable "runner_subnet_address_prefix" {
  description = "The address prefix for the GitHub Actions Runner VM subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "firewall_subnet_name" {
  description = "The name of the Azure Firewall subnet."
  type        = string
  default     = "AzureFirewallSubnet" # This name is mandatory for Azure Firewall
}

variable "firewall_subnet_address_prefix" {
  description = "The address prefix for the Azure Firewall subnet."
  type        = string
  default     = "10.0.3.0/24"
}

variable "bastion_subnet_name" {
  description = "The name of the Azure Bastion subnet."
  type        = string
  default     = "AzureBastionSubnet" # This name is mandatory for Azure Bastion
}

variable "bastion_subnet_address_prefix" {
  description = "The address prefix for the Azure Bastion subnet."
  type        = string
  default     = "10.0.4.0/26" # Bastion subnet requires a /26 or larger prefix
}

variable "acr_subnet_name" {
  description = "The name of the ACR subnet."
  type        = string
  default     = "acr-subnet"
}

variable "acr_subnet_address_prefix" {
  description = "The address prefix for the ACR subnet."
  type        = string
  default     = "10.0.5.0/24"
}