resource "azurerm_subnet" "subnets" {
  for_each = var.subnets
    name                 = each.key == var.gatewaysubnet_subnet_name ? each.key : "${var.name-vars["account"]}-${var.name-vars["name"]}-${each.key}"
    resource_group_name  = azurerm_resource_group.rg-vnet.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = each.value
    service_endpoints    = each.key == var.gatewaysubnet_subnet_name || each.key == var.public_subnet_name ? null : var.service_endpoints

    dynamic "delegation" {
      for_each = { for k, v in var.set_subnet_specific_delegation : k => v
          if k = each.key
      }
        content {
          name = "delegation"
          service_delegation {
            name = delegation.value["name"]
            actions = delegation.value["actions"]
          }
        }
    }
}
