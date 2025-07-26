output "resource_group_name" {
  description = "The name of the main resource group."
  value       = module.networking.resource_group_name
}

output "vnet_id" {
  description = "The ID of the Virtual Network."
  value       = module.networking.vnet_id
}


output "aks_cluster_name" {
  description = "The name of the AKS cluster."
  value       = module.aks_acr.aks_cluster_name
}

output "aks_private_fqdn" {
  description = "The private FQDN of the AKS cluster API server."
  value       = module.aks_acr.aks_private_fqdn
}

output "acr_login_server" {
  description = "The login server URL for the Azure Container Registry."
  value       = module.aks_acr.acr_login_server
}

output "aks_kube_config_raw" {
  description = "The raw Kubernetes configuration for the AKS cluster."
  value       = module.aks_acr.aks_kube_config_raw
  sensitive   = true # Mark as sensitive to prevent showing in plan/apply output
}

output "runner_vm_name" {
  description = "The name of the GitHub Actions Runner VM."
  value       = module.jump_host.runner_vm_name
}

output "runner_vm_private_ip_address" {
  description = "The private IP address of the GitHub Actions Runner VM."
  value       = module.jump_host.runner_vm_private_ip_address
}

output "firewall_public_ip_address" {
  description = "The public IP address of the Azure Firewall."
  value       = module.security.firewall_public_ip_address
}

output "firewall_private_ip_address" {
  description = "The private IP address of the Azure Firewall."
  value       = module.security.firewall_private_ip_address
}

output "bastion_host_name" {
  description = "The name of the Azure Bastion Host."
  value       = module.bastion.bastion_host_name
}