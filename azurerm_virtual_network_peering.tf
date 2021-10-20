resource "azurerm_virtual_network_peering" "peerings" {
  for_each = var.peer_vnet_id
    name                         = each.key
    resource_group_name          = azurerm_resource_group.rg-vnet.name
    virtual_network_name         = azurerm_virtual_network.vnet.name
    remote_virtual_network_id    = each.value["remote_virtual_network_id"]
    allow_virtual_network_access = each.value["allow_virtual_network_access"]
    allow_forwarded_traffic      = each.value["allow_forwarded_traffic"]
    allow_gateway_transit        = each.value["allow_gateway_transit"]
    use_remote_gateways          = each.value["use_remote_gateways"]
}