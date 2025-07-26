# Output the VM details
output "runner_vm_id" {
  description = "The ID of the GitHub Actions Runner VM."
  value       = azurerm_linux_virtual_machine.main.id
}

output "runner_vm_private_ip_address" {
  description = "The private IP address of the GitHub Actions Runner VM."
  value       = azurerm_network_interface.main.private_ip_address
}

output "runner_vm_name" {
  description = "The name of the GitHub Actions Runner VM."
  value       = azurerm_linux_virtual_machine.main.name
}
