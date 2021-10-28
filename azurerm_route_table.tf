/* Public Subnet Routing Table */
resource "azurerm_route_table" "router" {
  for_each = var.subnets
    name                = var.vnet-name == "" ? "${var.name-vars["account"]}-${var.region}-${var.name-vars["name"]}-${each.key}rt" : "${var.vnet-name}-${each.key}rt"
    location            = var.region
    resource_group_name = azurerm_resource_group.rg-vnet.name
    tags                = merge( var.tags, local.resource-tags["azurerm_route_table"] )
}

resource "azurerm_subnet_route_table_association" "router" {
  for_each = var.subnets
    subnet_id      = azurerm_subnet.subnets[each.key].id
    route_table_id = azurerm_route_table.router[each.key].id
}

resource "azurerm_route" "pubrt-default" {
  for_each = { for k, v in var.subnets: k => v if k == var.public_subnet_name }
    name                = "DefaultGateway"
    resource_group_name = azurerm_resource_group.rg-vnet.name
    route_table_name    = azurerm_route_table.router[var.public_subnet_name].name
    address_prefix      = "0.0.0.0/0"
    next_hop_type       = "Internet"
}

resource "azurerm_route" "defualt_routes" {
  for_each = { for k, v in var.next_hop_in_ip_address: k => v if k != var.public_subnet_name && k != var.gatewaysubnet_subnet_name }
    name                   = "DefaultGateway"
    resource_group_name    = azurerm_resource_group.rg-vnet.name
    route_table_name       = azurerm_route_table.router[each.key].name
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = each.value == "Internet" ? "Internet" : "VirtualAppliance"
    next_hop_in_ip_address = each.value == "Internet" ? null : each.value
}
/*
resource "azurerm_route" "subnet_specific_routes" {
  for_each = { for k, v in local.subnet_specific_routes_add : v.name => v }
    name                   = each.value["name"]
    resource_group_name    = azurerm_resource_group.rg-vnet.name
    route_table_name       = azurerm_route_table.router[each.value.key].name
    address_prefix         = each.value.cidr
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = each.value["next_hop_in_ip_address"]
}
*/