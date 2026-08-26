output "resource_group_name" {
  value = azurerm_resource_group.cloud_platform.name
}

output "vnet_name" {
  value = azurerm_virtual_network.cloud_platform.name
}

output "vnet_address_space" {
  value = azurerm_virtual_network.cloud_platform.address_space
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.cloud_platform.name
}

output "aks_kubernetes_version" {
  value = azurerm_kubernetes_cluster.cloud_platform.kubernetes_version
}

output "aks_fqdn" {
  value = azurerm_kubernetes_cluster.cloud_platform.fqdn
}

output "acr_name" {
  value = azurerm_container_registry.cloud_platform.name
}

output "acr_login_server" {
  value = azurerm_container_registry.cloud_platform.login_server
}