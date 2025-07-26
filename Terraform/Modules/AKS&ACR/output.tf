# Output the AKS cluster details
output "aks_cluster_id" {
  description = "The ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_private_fqdn" {
  description = "The private FQDN of the AKS cluster API server."
  value       = azurerm_kubernetes_cluster.main.private_fqdn
}

output "aks_kube_config_raw" {
  description = "The raw Kubernetes configuration for the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true # Mark as sensitive to prevent showing in plan/apply output
}

output "aks_identity_principal_id" {
  description = "The Principal ID of the AKS cluster's User Assigned Managed Identity."
  value       = azurerm_user_assigned_identity.aks_identity.principal_id
}

output "acr_login_server" {
  description = "The login server URL for the Azure Container Registry."
  value       = azurerm_container_registry.main.login_server
}

output "acr_id" {
  description = "The ID of the Azure Container Registry."
  value       = azurerm_container_registry.main.id
}