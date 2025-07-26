# Define variables for AKS cluster configuration
variable "resource_group_name" {
  description = "The name of the resource group where AKS will be deployed."
  type        = string
}

variable "location" {
  description = "The Azure region where AKS will be deployed."
  type        = string
}

variable "vnet_id" {
  description = "The ID of the Virtual Network where AKS subnets reside."
  type        = string
}

variable "aks_subnet_id" {
  description = "The ID of the subnet dedicated to AKS."
  type        = string
}

variable "acr_subnet_id" {
  description = "The ID of the subnet dedicated to ACR private endpoint."
  type        = string
}

variable "route_table_id" { # New variable for the route table ID
  description = "The ID of the custom route table associated with AKS subnet."
  type        = string
}


variable "cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
  default     = "aks-private-cluster"
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.31" # Choose a supported AKS version
}

variable "node_vm_size" {
  description = "The VM size for the AKS agent nodes."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "node_count" {
  description = "The number of agent nodes in the default node pool."
  type        = number
  default     = 2
}

variable "dns_prefix" {
  description = "The DNS prefix for the AKS cluster."
  type        = string
  default     = "aks-private"
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy for AKS."
  type        = bool
  default     = true
}

variable "enable_rbac" {
  description = "Enable Kubernetes RBAC."
  type        = bool
  default     = true
}

variable "enable_managed_aad" {
  description = "Enable Managed Azure AD integration for AKS."
  type        = bool
  default     = true
}

variable "acr_name" {
  description = "The name of the Azure Container Registry."
  type        = string
  default     = "akssecureacr"
}

variable "acr_sku" {
  description = "The SKU of the Azure Container Registry."
  type        = string
  default     = "Premium" # Premium SKU is required for Private Link
}
