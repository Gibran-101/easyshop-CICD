# Container for all project resources - simplifies management and cost tracking
# Enables bulk operations like viewing costs, applying policies, or cleanup
resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-rg"
  location = var.location
  tags     = var.tags
}

# Private network foundation for the entire project
# 10.0.0.0/16 provides 65k IPs with room for multiple subnets and future growth
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# Dedicated subnet for AKS nodes and pods - isolated from other workloads
# Service endpoints enable direct, secure access to Azure services without internet routing
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  # Direct connectivity to Azure services - more secure and performant than public internet
  service_endpoints = [
    "Microsoft.KeyVault",          # For application secrets
    "Microsoft.ContainerRegistry", # For container image pulls
    "Microsoft.Storage",           # For persistent volumes if needed
    "Microsoft.Sql"                # Reserved for future database needs
  ]
}

# Network firewall controlling traffic flow to/from the AKS subnet
# Configured for web application traffic - HTTP/HTTPS from internet
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.project_name}-aks-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  # Allow web traffic for the e-commerce application
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow secure web traffic for the e-commerce application
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Apply the network security rules to the AKS subnet
# This binding activates the firewall rules for all resources in the subnet
resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}
