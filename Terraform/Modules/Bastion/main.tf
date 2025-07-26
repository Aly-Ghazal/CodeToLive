# Create a Public IP for Azure Bastion
# This public IP is required for the Bastion service itself.
resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.bastion_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard" # Standard SKU is required for Bastion
}

# Create the Azure Bastion Host
resource "azurerm_bastion_host" "main" {
  name                = var.bastion_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "ipconfig1"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }

  tags = {
    Environment = "Dev"
    Project     = "SecureAKS"
    ManagedBy   = "Terraform"
    Role        = "Bastion"
  }
}
