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