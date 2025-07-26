# Output the Bastion Host details
output "bastion_host_id" {
  description = "The ID of the Azure Bastion Host."
  value       = azurerm_bastion_host.main.id
}

output "bastion_host_name" {
  description = "The name of the Azure Bastion Host."
  value       = azurerm_bastion_host.main.name
}

output "bastion_public_ip_id" {
  description = "The ID of the Public IP associated with the Azure Bastion Host."
  value       = azurerm_public_ip.bastion_pip.id
}