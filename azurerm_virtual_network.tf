resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet-name == "" ? "${var.name-vars["account"]}-${var.region}-${var.name-vars["name"]}" : var.vnet-name
  address_space       = var.vnet-cidrs
  location            = var.region
  resource_group_name = azurerm_resource_group.rg-vnet.name
  dns_servers         = var.domain_name_servers
  tags                = merge( var.tags, local.resource-tags["azurerm_virtual_network"] )
}
