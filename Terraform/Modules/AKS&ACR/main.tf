# Create a System Assigned Managed Identity for AKS
# This identity will be used by the AKS cluster for Azure resource interactions.
resource "azurerm_user_assigned_identity" "aks_identity" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = "${var.cluster_name}-identity"
}

# Grant AKS Managed Identity Network Contributor role on the custom Route Table
resource "azurerm_role_assignment" "aks_network_contributor_on_rt" {
  scope                = var.route_table_id # Use the new input variable for the route table ID
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}
# Grant AKS Managed Identity Contributor role on the VNet
resource "azurerm_role_assignment" "aks_vnet_contributor" {
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
  depends_on           = [azurerm_kubernetes_cluster.aks_cluster]
}

# Create the Private AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  # Enable private cluster
  private_cluster_enabled = true
  # Private DNS Zone will be automatically created in the resource group
  # for the AKS cluster.
  # For full private DNS resolution, you might need to link this zone to your VNet.

  # Use Managed Identity for the cluster
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }



  # Network Profile for Azure CNI
  network_profile {
    network_plugin    = "kubenet"
    dns_service_ip    = "10.0.6.10" # Example DNS service IP within your VNet address space
    service_cidr      = "10.0.6.0/24" # Example service CIDR, ensure it doesn't overlap with VNet
    pod_cidr          = "10.244.0.0/16" # Example pod CIDR, ensure it doesn't overlap
    outbound_type     = "userDefinedRouting" # Essential for integrating with Azure Firewall
  }

  # Default Node Pool configuration
  default_node_pool {
    name                 = "default"
    vm_size              = var.node_vm_size
    node_count           = var.node_count
    vnet_subnet_id       = var.aks_subnet_id
  }

  # Enable RBAC
  role_based_access_control_enabled = var.enable_rbac

  # # Enable Managed Azure AD integration
  # azure_active_directory_role_based_access_control {
  #   managed                = var.enable_managed_aad
  #   azure_rbac_enabled     = var.enable_managed_aad
  #   # If managed AAD is true, admin_group_object_ids can be specified
  #   # admin_group_object_ids = ["<Azure AD Group Object ID>"]
  # }

  # Enable Azure Policy for AKS for ref https://learn.microsoft.com/en-ie/azure/governance/policy/concepts/policy-for-kubernetes
  # azure_policy_enabled = var.enable_azure_policy

  # Add tags for better resource management
  tags = {
    Environment = "Dev"
    Project     = "SecureAKS"
    ManagedBy   = "Terraform"
  }
}


# --- Azure Container Registry (ACR) Configuration ---

# Create Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = false # Best practice to disable admin user for managed identity usage
}

# Create a Private Endpoint for ACR
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                = "${var.acr_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.acr_subnet_id # Use the dedicated ACR subnet

  private_service_connection {
    name                           = "${var.acr_name}-psc"
    private_connection_resource_id = azurerm_container_registry.main.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
}

# Create a Private DNS Zone for ACR
# This is a standard private DNS zone name for Azure Container Registry
resource "azurerm_private_dns_zone" "acr_private_dns_zone" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name # Can be in a shared DNS RG if preferred
}

# Link the ACR Private DNS Zone to the Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "acr_private_dns_link" {
  name                  = "${var.acr_name}-privatedns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.acr_private_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

# Create a Private DNS Zone A Record for the ACR Private Endpoint
resource "azurerm_private_dns_a_record" "acr_a_record" {
  name                = azurerm_container_registry.main.name
  zone_name           = azurerm_private_dns_zone.acr_private_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.acr_private_endpoint.private_service_connection[0].private_ip_address]
}

# Grant AKS Managed Identity AcrPull role on the ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}
