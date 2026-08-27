resource "azurerm_kubernetes_cluster" "cloud_platform" {
  name                = "aks-cloud-platform-dev"
  location            = azurerm_resource_group.cloud_platform.location
  resource_group_name = azurerm_resource_group.cloud_platform.name
  dns_prefix          = "aks-cloud-platform-dev"

  kubernetes_version = "1.34"

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "standard_b4s_v2"
    vnet_subnet_id = azurerm_subnet.aks.id
    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    tenant_id          = "604f1a96-cbe8-43f8-abbf-f8eaf5d85730"
    azure_rbac_enabled = true
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