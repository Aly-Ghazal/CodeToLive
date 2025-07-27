# Create a Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Create a Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space
}

# NSG for AKS Subnet
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.aks_subnet_name}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Basic NSG rules for AKS - these will be refined later for security
  # Allow all outbound traffic by default for now (can be restricted by Firewall)
  security_rule {
    name                       = "AllowOutboundAll"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # Deny all inbound traffic by default for now
  security_rule {
    name                       = "DenyInboundAll"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
     access                                     = "Allow"
     description                                = ""
     destination_address_prefix                 = "*"
     destination_address_prefixes               = []
     destination_application_security_group_ids = []
     destination_port_range                     = "*"
     destination_port_ranges                    = []
     direction                                  = "Inbound"
     name                                       = "AllowAnyCustomAnyInbound"
     priority                                   = 101
     protocol                                   = "*"
     source_address_prefix                      = "*"
     source_address_prefixes                    = []
     source_application_security_group_ids      = []
     source_port_range                          = "*"
     source_port_ranges                         = []
  }
  security_rule{
     access                                     = "Allow"
     description                                = ""
     destination_address_prefix                 = "*"
     destination_address_prefixes               = []
     destination_application_security_group_ids = []
     destination_port_range                     = "*"
     destination_port_ranges                    = []
     direction                                  = "Inbound"
     name                                       = "AllowCidrBlockCustom_30850Inbound"
     priority                                   = 110
     protocol                                   = "*"
     source_address_prefix                      = "168.63.129.16"
     source_address_prefixes                    = []
     source_application_security_group_ids      = []
     source_port_range                          = "*"
     source_port_ranges                         = []
  }
  security_rule{
     access                                     = "Allow"
     description                                = ""
     destination_address_prefix                 = "*"
     destination_address_prefixes               = []
     destination_application_security_group_ids = []
     destination_port_range                     = "*"
     destination_port_ranges                    = []
     direction                                  = "Inbound"
     name                                       = "AllowFirewallAnyInbound"
     priority                                   = 100
     protocol                                   = "*"
     source_address_prefix                      = "172.190.48.66"
     source_address_prefixes                    = []
     source_application_security_group_ids      = []
     source_port_range                          = "*"
     source_port_ranges                         = []
  }
  security_rule{
     access                                     = "Allow"
     description                                = ""
     destination_address_prefix                 = "*"
     destination_address_prefixes               = []
     destination_application_security_group_ids = []
     destination_port_range                     = "*"
     destination_port_ranges                    = []
     direction                                  = "Inbound"
     name                                       = "AllowFirewallPrivateIPAnyInbound"
     priority                                   = 120
     protocol                                   = "*"
     source_address_prefix                      = "10.0.3.4"
     source_address_prefixes                    = []
     source_application_security_group_ids      = []
     source_port_range                          = "*"
     source_port_ranges                         = []
  }
  security_rule{
    access                                     = "Allow"
    description                                = ""
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_range                     = "*"
    destination_port_ranges                    = []
    direction                                  = "Outbound"
    name                                       = "AllowOutboundAll"
    priority                                   = 100
    protocol                                   = "*"
    source_address_prefix                      = "*"
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
    source_port_range                          = "*"
    source_port_ranges                         = []
  }
  
}

# Subnet for AKS
resource "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.aks_subnet_address_prefix]
}

resource "azurerm_subnet_network_security_group_association" "aks_subnet_nsg" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}


# NSG for GitHub Actions Runner Subnet
resource "azurerm_network_security_group" "runner_nsg" {
  name                = "${var.runner_subnet_name}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Allow SSH/RDP inbound from Bastion (if applicable) and outbound to GitHub
  security_rule {
    name                       = "AllowOutboundALL"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*" # Azure service tag for GitHub
    description                = "Allow outbound HTTPS to GitHub for runner"
  }
  security_rule {
    name                       = "AllowInboundSSHFromBastion"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22" # SSH port
    source_address_prefix      = azurerm_subnet.bastion_subnet.address_prefixes[0] # Allow from Bastion subnet
    destination_address_prefix = "*"
    description                = "Allow SSH from Bastion"
  }
  security_rule {
    name                       = "DenyInboundAll"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Subnet for GitHub Actions Runner VM
resource "azurerm_subnet" "runner_subnet" {
  name                 = var.runner_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.runner_subnet_address_prefix]
}

resource "azurerm_subnet_network_security_group_association" "runner_subnet_nsg" {
  subnet_id                 = azurerm_subnet.runner_subnet.id
  network_security_group_id = azurerm_network_security_group.runner_nsg.id
}

# NSG for Azure Firewall Subnet (typically not directly associated with an NSG, Firewall manages its own rules)
# However, for completeness, we define it, though it won't be explicitly attached to the FirewallSubnet.
# Azure FirewallSubnet does not support NSG association.

# Subnet for Azure Firewall
# Note: AzureFirewallSubnet cannot be associated with an NSG.
resource "azurerm_subnet" "firewall_subnet" {
  name                 = var.firewall_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.firewall_subnet_address_prefix]
}

# NSG for Azure Bastion Subnet
resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "${var.bastion_subnet_name}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Required rules for Azure Bastion
  security_rule {
    name                       = "AllowHttpsInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "Allow HTTPS inbound from Internet for Bastion"
  }
  security_rule {
    name                       = "AllowGatewayManagerInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
    description                = "Allow GatewayManager inbound"
  }
  security_rule {
    name                       = "AllowAzureCloudInbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureCloud"
    destination_address_prefix = "*"
    description                = "Allow AzureCloud inbound"
  }
  security_rule {
    name                       = "AllowOutboundSSH"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = var.runner_subnet_address_prefix # Allow outbound to runner subnet
    description                = "Allow outbound SSH to runner VM"
  }
  security_rule {
    name                       = "AllowOutboundRDP"
    priority                   = 140
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = var.runner_subnet_address_prefix # Allow outbound to runner subnet
    description                = "Allow outbound RDP to runner VM"
  }
  security_rule {
    name                       = "AllowVnetOutbound"
    priority                   = 150
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
    description                = "Allow outbound to VNet"
  }
  security_rule {
    name                       = "AllowAzureCloudOutbound"
    priority                   = 160
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
    description                = "Allow outbound to AzureCloud"
  }
}

# Subnet for Azure Bastion
resource "azurerm_subnet" "bastion_subnet" {
  name                 = var.bastion_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.bastion_subnet_address_prefix]
}

resource "azurerm_subnet_network_security_group_association" "bastion_subnet_nsg" {
  subnet_id                 = azurerm_subnet.bastion_subnet.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}

# NSG for ACR Subnet
resource "azurerm_network_security_group" "acr_nsg" {
  name                = "${var.acr_subnet_name}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Rules for ACR private endpoint connectivity
  security_rule {
    name                       = "AllowInboundFromAKS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443" # HTTPS for ACR
    source_address_prefix      = var.aks_subnet_address_prefix # Allow from AKS subnet
    destination_address_prefix = "*"
    description                = "Allow inbound HTTPS from AKS to ACR"
  }
  security_rule {
    name                       = "DenyAllOtherInbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowOutboundAll"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow all outbound (can be restricted by Firewall)"
  }
  security_rule { 
     access                                     = "Allow"
     description                                = ""
     destination_address_prefix                 = "*"
     destination_address_prefixes               = []
     destination_application_security_group_ids = []
     destination_port_range                     = "443"
     destination_port_ranges                    = []
     direction                                  = "Inbound"
     name                                       = "AllowTagHTTPSInbound"
     priority                                   = 150
     protocol                                   = "Tcp"
     source_address_prefix                      = "VirtualNetwork"
     source_address_prefixes                    = []
     source_application_security_group_ids      = []
     source_port_range                          = "*"
     source_port_ranges                         = []
  }
  security_rule {
     access                                     = "Allow"
     description                                = ""
     destination_address_prefix                 = "*"
     destination_address_prefixes               = []
     destination_application_security_group_ids = []
     destination_port_range                     = "80"
     destination_port_ranges                    = []
     direction                                  = "Inbound"
     name                                       = "AllowTagHTTPInbound"
     priority                                   = 151
     protocol                                   = "Tcp"
     source_address_prefix                      = "VirtualNetwork"
     source_address_prefixes                    = []
     source_application_security_group_ids      = []
     source_port_range                          = "*"
     source_port_ranges                         = []
  }
}

# Subnet for ACR
resource "azurerm_subnet" "acr_subnet" {
  name                 = var.acr_subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.acr_subnet_address_prefix]
}

resource "azurerm_subnet_network_security_group_association" "acr_subnet_nsg" {
  subnet_id                 = azurerm_subnet.acr_subnet.id
  network_security_group_id = azurerm_network_security_group.acr_nsg.id
}
