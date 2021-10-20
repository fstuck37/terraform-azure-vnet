resource "azurerm_subnet" "subnets" {
  for_each = var.subnets
    name                 = each.key == "GatewaySubnet" ? each.key : "${var.name-vars["account"]}-${var.name-vars["name"]}-${each.key}"
    resource_group_name  = azurerm_resource_group.rg-vnet.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = each.value
    service_endpoints    = each.key == "GatewaySubnet" || each.key == "pub" ? null : var.service_endpoints
}