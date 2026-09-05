data "azurerm_client_config" "current" {}

resource "azurerm_kubernetes_cluster" "cloud_platform" {
  name                = "aks-${local.name_prefix}"
  location            = azurerm_resource_group.cloud_platform.location
  resource_group_name = azurerm_resource_group.cloud_platform.name
  dns_prefix          = "aks-${local.name_prefix}"

  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name           = "system"
    node_count     = var.aks_node_count
    vm_size        = var.aks_vm_size
    vnet_subnet_id = azurerm_subnet.aks.id

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    tenant_id          = data.azurerm_client_config.current.tenant_id
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