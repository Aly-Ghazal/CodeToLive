variable "resource_group_name" {
  description = "The name of the resource group where the Firewall will be deployed."
  type        = string
}

variable "location" {
  description = "The Azure region where the Firewall will be deployed."
  type        = string
}

variable "firewall_subnet_id" {
  description = "The ID of the subnet dedicated to Azure Firewall (AzureFirewallSubnet)."
  type        = string
}

variable "firewall_name" {
  description = "The name of the Azure Firewall."
  type        = string
  default     = "aks-secure-firewall"
}
