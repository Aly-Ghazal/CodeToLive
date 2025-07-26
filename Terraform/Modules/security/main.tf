# Create a Public IP for Azure Firewall
# This public IP is required for the Firewall service itself.
resource "azurerm_public_ip" "firewall_pip" {
  name                = "${var.firewall_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard" # Standard SKU is required for Firewall
}

# Create the Azure Firewall
resource "azurerm_firewall" "main" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet" # Standard SKU for VNet deployments
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }

  tags = {
    Environment = "Dev"
    Project     = "SecureAKS"
    ManagedBy   = "Terraform"
    Role        = "Firewall"
  }
}

# --- Azure Firewall Network Rules ---
# These rules define traffic based on IP address, port, and protocol.

# Allow outbound DNS traffic from AKS and Runner to Azure DNS
resource "azurerm_firewall_network_rule_collection" "dns_outbound" {
  name                = "AllowDNSOutbound"
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name                  = "AllowAzureDNS"
    source_addresses      = ["*"] # Or specific subnets like aks_subnet_address_prefix, runner_subnet_address_prefix
    destination_addresses = ["AzureCloud"] # Azure service tag for Azure DNS
    destination_ports     = ["53"]
    protocols             = ["UDP", "TCP"]
  }
}

# Allow outbound NTP traffic
resource "azurerm_firewall_network_rule_collection" "ntp_outbound" {
  name                = "AllowNTPOutbound"
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = 110
  action              = "Allow"

  rule {
    name                  = "AllowNTP"
    source_addresses      = ["*"]
    destination_addresses = ["*"] # Or specific NTP servers
    destination_ports     = ["123"]
    protocols             = ["UDP"]
  }
}

# --- Azure Firewall Application Rules ---
# These rules define traffic based on FQDNs.

# Allow outbound traffic for GitHub Actions Runner to GitHub FQDNs
resource "azurerm_firewall_application_rule_collection" "github_runner_outbound" {
  name                = "AllowGitHubRunnerOutbound"
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name             = "GitHubActions"
    source_addresses = ["*"] # Or specific runner subnet IP range
    target_fqdns     = [
      "github.com",
      "api.github.com",
      "pipelines.actions.githubusercontent.com",
      "codeload.github.com",
      "*.blob.core.windows.net", # For runner updates/downloads
      "*.githubusercontent.com" # For actions/checkout and other actions
    ]
    protocol {
      port = 443
      type = "Https"
    }
  }
}

# Allow outbound traffic for AKS to required Azure services
# This is a minimal set; AKS has many outbound dependencies.
# Refer to Azure AKS documentation for a comprehensive list.
resource "azurerm_firewall_application_rule_collection" "aks_outbound" {
  name                = "AllowAKSOutbound"
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = 110
  action              = "Allow"

  rule {
    name             = "AzureServices"
    source_addresses = ["*"] # Or specific AKS subnet IP range
    target_fqdns     = [
      "mcr.microsoft.com", # Microsoft Container Registry
      "*.data.mcr.microsoft.com",
      "*.cdn.mcr.microsoft.com",
      "management.azure.com", # Azure Resource Manager
      "login.microsoftonline.com", # Azure AD
      "graph.microsoft.com", # Microsoft Graph
      "*.blob.core.windows.net", # Storage accounts for diagnostics, etc.
      "*.table.core.windows.net",
      "*.queue.core.windows.net",
      "*.vault.azure.net", # Azure Key Vault
      "dc.services.visualstudio.com", # Application Insights
      "*.oms.opinsights.azure.com", # Log Analytics
      "*.monitoring.azure.com" # Azure Monitor
    ]
    protocol {
      port = 443
      type = "Https"
    }
  }
  rule {
    name             = "all"
    source_addresses = ["*"] # Or specific AKS subnet IP range
    target_fqdns     = ["*"] # Be cautious with this broad rule in production
    protocol {
      port = 80
      type = "Http"
    }
    protocol {
      port = 443
      type = "Https"
    }
  }
}
