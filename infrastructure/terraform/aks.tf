resource "azurerm_kubernetes_cluster" "cloud_platform" {
  name                = "aks-cloud-platform-dev"
  location            = azurerm_resource_group.cloud_platform.location
  resource_group_name = azurerm_resource_group.cloud_platform.name
  dns_prefix          = "aks-cloud-platform-dev"

  kubernetes_version = "1.30"

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "azure"

    pod_cidr       = "10.20.0.0/16"
    service_cidr   = "10.30.0.0/16"
    dns_service_ip = "10.30.0.10"
  }
}