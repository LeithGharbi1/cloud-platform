resource "azurerm_container_registry" "cloud_platform" {
  name                = replace("acr${local.name_prefix}01", "-", "")
  resource_group_name = azurerm_resource_group.cloud_platform.name
  location            = azurerm_resource_group.cloud_platform.location

  sku           = var.acr_sku
  admin_enabled = false
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.cloud_platform.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.cloud_platform.kubelet_identity[0].object_id
}