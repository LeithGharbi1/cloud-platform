resource "azurerm_resource_group" "cloud_platform" {
  name     = "rg-cloud-platform-dev"
  location = var.location
}

resource "azurerm_virtual_network" "cloud_platform" {
  name                = "vnet-cloud-platform-dev"
  location            = azurerm_resource_group.cloud_platform.location
  resource_group_name = azurerm_resource_group.cloud_platform.name

  address_space = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.cloud_platform.name
  virtual_network_name = azurerm_virtual_network.cloud_platform.name

  address_prefixes = ["10.10.1.0/24"]
}