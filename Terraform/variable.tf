
variable "resource_group_name" {
  description = "The name of the main resource group."
  type        = string
  default     = "aks-secure-rg"
}

variable "location" {
  description = "The Azure region for resource deployment."
  type        = string
  default     = "East US"
}

# Networking Variables
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
  default     = "AzureFirewallSubnet"
}

variable "firewall_subnet_address_prefix" {
  description = "The address prefix for the Azure Firewall subnet."
  type        = string
  default     = "10.0.3.0/24"
}

variable "bastion_subnet_name" {
  description = "The name of the Azure Bastion subnet."
  type        = string
  default     = "AzureBastionSubnet"
}

variable "bastion_subnet_address_prefix" {
  description = "The address prefix for the Azure Bastion subnet."
  type        = string
  default     = "10.0.4.0/26"
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

# AKS Variables
variable "aks_cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
  default     = "aks-private-cluster"
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.31"
}

variable "aks_node_vm_size" {
  description = "The VM size for the AKS agent nodes."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "aks_node_count" {
  description = "The number of agent nodes in the default node pool."
  type        = number
  default     = 1
}

variable "aks_dns_prefix" {
  description = "The DNS prefix for the AKS cluster."
  type        = string
  default     = "aks-private"
}

# ACR Variables
variable "acr_name" {
  description = "The name of the Azure Container Registry."
  type        = string
  default     = "akssecureacr"
}

variable "acr_sku" {
  description = "The SKU of the Azure Container Registry."
  type        = string
  default     = "Premium"
}

# GitHub Actions Runner VM (Jump Host) Variables
variable "runner_vm_name" {
  description = "The name of the GitHub Actions Runner VM."
  type        = string
  default     = "github-runner-vm"
}

variable "runner_vm_size" {
  description = "The VM size for the GitHub Actions Runner VM."
  type        = string
  default     = "Standard_B1ms"
}

variable "runner_admin_username" {
  description = "The admin username for the runner VM."
  type        = string
  default     = "azureuser"
}

variable "runner_admin_password" {
  description = "The admin password for the runner VM."
  type        = string
  sensitive = true
}

# Azure Firewall (Security) Variables
variable "firewall_name" {
  description = "The name of the Azure Firewall."
  type        = string
  default     = "aks-secure-firewall"
}

# Azure Bastion Variables
variable "bastion_name" {
  description = "The name of the Azure Bastion host."
  type        = string
  default     = "aks-bastion-host"
}