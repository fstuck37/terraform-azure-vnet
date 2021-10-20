output "azurerm_virtual_network_id" {
  value = azurerm_virtual_network.vnet.id
}

output "azurerm_virtual_network_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnets" {
  value = local.subnets
}

output "route_table_ids" {
  value = local.route_table_ids
}

output "azurerm_resource_group_name" {
  value = azurerm_resource_group.rg-vnet.name
}

output "network_security_group_names" {
  value = local.network_security_group_names
}
