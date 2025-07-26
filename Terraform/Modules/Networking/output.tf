# Output the VNet and Subnet IDs for use in other modules
output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.main.id
}

output "aks_subnet_id" {
  description = "The ID of the AKS subnet."
  value       = azurerm_subnet.aks_subnet.id
}

output "aks_subnet_name" {
  description = "The name of the AKS subnet."
  value       = azurerm_subnet.aks_subnet.name
}

output "runner_subnet_id" {
  description = "The ID of the GitHub Actions Runner VM subnet."
  value       = azurerm_subnet.runner_subnet.id
}

output "runner_subnet_name" {
  description = "The name of the GitHub Actions Runner VM subnet."
  value       = azurerm_subnet.runner_subnet.name
}

output "firewall_subnet_id" {
  description = "The ID of the Azure Firewall subnet."
  value       = azurerm_subnet.firewall_subnet.id
}

output "firewall_subnet_name" {
  description = "The name of the Azure Firewall subnet."
  value       = azurerm_subnet.firewall_subnet.name
}

output "bastion_subnet_id" {
  description = "The ID of the Azure Bastion subnet."
  value       = azurerm_subnet.bastion_subnet.id
}

output "bastion_subnet_name" {
  description = "The name of the Azure Bastion subnet."
  value       = azurerm_subnet.bastion_subnet.name
}

output "acr_subnet_id" {
  description = "The ID of the ACR subnet."
  value       = azurerm_subnet.acr_subnet.id
}

output "acr_subnet_name" {
  description = "The name of the ACR subnet."
  value       = azurerm_subnet.acr_subnet.name
}
