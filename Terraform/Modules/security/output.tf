# Output the Firewall details
output "firewall_id" {
  description = "The ID of the Azure Firewall."
  value       = azurerm_firewall.main.id
}

output "firewall_name" {
  description = "The name of the Azure Firewall."
  value       = azurerm_firewall.main.name
}

output "firewall_public_ip_address" {
  description = "The public IP address of the Azure Firewall."
  value       = azurerm_public_ip.firewall_pip.ip_address
}

output "firewall_private_ip_address" {
  description = "The private IP address of the Azure Firewall."
  value       = azurerm_firewall.main.ip_configuration[0].private_ip_address
}