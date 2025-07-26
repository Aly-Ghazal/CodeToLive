# Define variables for Azure Bastion configuration
variable "resource_group_name" {
  description = "The name of the resource group where Bastion will be deployed."
  type        = string
}

variable "location" {
  description = "The Azure region where Bastion will be deployed."
  type        = string
}

variable "bastion_subnet_id" {
  description = "The ID of the subnet dedicated to Azure Bastion (AzureBastionSubnet)."
  type        = string
}

variable "bastion_name" {
  description = "The name of the Azure Bastion host."
  type        = string
  default     = "aks-bastion-host"
}
