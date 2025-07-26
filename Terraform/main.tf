# This is the root configuration file that orchestrates all modules.

# Module for Azure Firewall (Security) - Must be deployed before Networking for its private IP
# to be available for UDRs in the Networking module.
module "security" {
  source = "./Modules/security"

  resource_group_name = var.resource_group_name
  location            = var.location
  # firewall_subnet_id will be passed from networking module once it's created,
  # but for the initial plan, we need a placeholder or ensure networking is applied first.
  # For a single apply, Terraform handles the dependency graph.
  firewall_subnet_id  = module.networking.firewall_subnet_id
  firewall_name       = var.firewall_name
}

# Module for Networking components (VNet, Subnets, NSGs, Route Table)
# This module now depends on the firewall's private IP for UDRs.
module "networking" {
  source = "./Modules/Networking"

  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space

  aks_subnet_name           = var.aks_subnet_name
  aks_subnet_address_prefix = var.aks_subnet_address_prefix

  runner_subnet_name           = var.runner_subnet_name
  runner_subnet_address_prefix = var.runner_subnet_address_prefix

  firewall_subnet_name           = var.firewall_subnet_name
  firewall_subnet_address_prefix = var.firewall_subnet_address_prefix

  bastion_subnet_name           = var.bastion_subnet_name
  bastion_subnet_address_prefix = var.bastion_subnet_address_prefix

  acr_subnet_name           = var.acr_subnet_name
  acr_subnet_address_prefix = var.acr_subnet_address_prefix

}


# Module for GitHub Actions Runner VM (Jump Host)
module "jump_host" {
  source = "./Modules/jump_host"

  resource_group_name = var.resource_group_name
  location            = var.location
  runner_subnet_id    = module.networking.runner_subnet_id

  vm_name           = var.runner_vm_name
  vm_size           = var.runner_vm_size
  admin_username    = var.runner_admin_username
  admin_password = var.runner_admin_password
}

# Module for Azure Bastion
module "bastion" {
  source = "./Modules/Bastion"

  resource_group_name = var.resource_group_name
  location            = var.location
  bastion_subnet_id   = module.networking.bastion_subnet_id
  bastion_name        = var.bastion_name
}
# --- Routing Configuration (User Defined Routes - UDRs) ---
# This section creates the Route Table and associates it with subnets,
# directing traffic through the Azure Firewall.
# This must be placed BEFORE the AKS module due to outbound_type = "userDefinedRouting".

# Create a Route Table
resource "azurerm_route_table" "main_route_table" {
  name                = "${var.vnet_name}-routetable"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Add a default route (0.0.0.0/0) to the Firewall's private IP
resource "azurerm_route" "default_to_firewall" {
  name                   = "default-to-firewall"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.main_route_table.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.security.firewall_private_ip_address
}

# Associate the Route Table with the AKS Subnet
resource "azurerm_subnet_route_table_association" "aks_subnet_association" {
  subnet_id      = module.networking.aks_subnet_id
  route_table_id = azurerm_route_table.main_route_table.id
}

# Associate the Route Table with the GitHub Actions Runner Subnet
resource "azurerm_subnet_route_table_association" "runner_subnet_association" {
  subnet_id      = module.networking.runner_subnet_id
  route_table_id = azurerm_route_table.main_route_table.id
}

# Module for AKS Cluster and ACR
module "aks_acr" {
  source = "./Modules/AKS&ACR"

  # Pass details from the networking module outputs
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_id             = module.networking.vnet_id
  aks_subnet_id       = module.networking.aks_subnet_id
  acr_subnet_id       = module.networking.acr_subnet_id
  route_table_id      = azurerm_route_table.main_route_table.id # Pass the route table ID

  # AKS-specific variables
  cluster_name       = var.aks_cluster_name
  kubernetes_version = var.kubernetes_version
  node_vm_size       = var.aks_node_vm_size
  node_count         = var.aks_node_count
  dns_prefix         = var.aks_dns_prefix

  # ACR-specific variables
  acr_name = var.acr_name
  acr_sku  = var.acr_sku
}