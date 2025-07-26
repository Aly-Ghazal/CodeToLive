# Define variables for the GitHub Actions Runner VM configuration
variable "resource_group_name" {
  description = "The name of the resource group where the VM will be deployed."
  type        = string
}

variable "location" {
  description = "The Azure region where the VM will be deployed."
  type        = string
}

variable "runner_subnet_id" {
  description = "The ID of the subnet dedicated to the GitHub Actions Runner VM."
  type        = string
}

variable "vm_name" {
  description = "The name of the GitHub Actions Runner VM."
  type        = string
  default     = "github-runner-vm"
}

variable "vm_size" {
  description = "The VM size for the GitHub Actions Runner VM."
  type        = string
  default     = "Standard_B1ms" # Adjust based on your pipeline needs
}

variable "admin_username" {
  description = "The admin username for the VM."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "The admin password for the VM."
  type        = string
  sensitive = true
}