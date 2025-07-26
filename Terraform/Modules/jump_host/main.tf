# Create a Network Interface for the VM
resource "azurerm_network_interface" "main" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.runner_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create the Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.main.id]
  disable_password_authentication = false
  admin_password = var.admin_password


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # Or Premium_LRS for better performance
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  

  tags = {
    Environment = "Dev"
    Project     = "SecureAKS"
    ManagedBy   = "Terraform"
    Role        = "GitHubRunner"
  }
}