resource "azurerm_public_ip" "gwyip" {
  for_each = var.express_route_circuit
    name                    = var.vnet-name == "" ? "gwyip-${var.name-vars["account"]}-${var.region}-${var.name-vars["name"]}" : "gwyip-${var.vnet-name}"
    location                = var.region
    resource_group_name     = azurerm_resource_group.rg-vnet.name
    allocation_method       = "Dynamic"
    idle_timeout_in_minutes = 4
    tags                    = merge( var.tags, local.resource-tags["azurerm_public_ip"] )
}

resource "azurerm_express_route_circuit" "ExpressRouteCircuit" {
  for_each = var.express_route_circuit
    name                  = "exprt-${var.name-vars["account"]}-${var.name-vars["name"]}-${each.key}"
    resource_group_name   = azurerm_resource_group.rg-vnet.name
    location              = var.region
    service_provider_name = each.value["service_provider_name"]
    peering_location      = each.value["peering_location"]
    bandwidth_in_mbps     = each.value["bandwidth_in_mbps"]
    sku {
      tier                = each.value["tier"]
      family              = each.value["family"]
    }
    tags                  = merge( var.tags, local.resource-tags["azurerm_express_route_circuit"] )
}


resource "azurerm_express_route_circuit_peering" "PrimaryAzurePrivatePeering" {
  for_each = var.express_route_circuit
    peering_type                  = each.value["peering_type"]
    express_route_circuit_name    = azurerm_express_route_circuit.ExpressRouteCircuit[each.key].name
    resource_group_name           = azurerm_resource_group.rg-vnet.name
    peer_asn                      = each.value["peer_asn"]
    primary_peer_address_prefix   = each.value["primary_peer_address_prefix"]
    shared_key			  = each.value["shared_key"]
    secondary_peer_address_prefix = each.value["secondary_peer_address_prefix"]
    vlan_id                       = each.value["vlan_id"]
}

resource "azurerm_virtual_network_gateway" "gwy" {
  for_each = var.express_route_circuit
    name                   = var.vnet-name == "" ? "gwy-${var.name-vars["account"]}-${var.region}-${var.name-vars["name"]}" : "gwy-${var.vnet-name}"
    resource_group_name    = azurerm_resource_group.rg-vnet.name
    location               = var.region
    type                   = var.azurerm_virtual_network_gateway_type
    enable_bgp             = var.azurerm_virtual_network_gateway_enable_bgp
    sku                    = var.azurerm_virtual_network_gateway_sku
    ip_configuration {
      public_ip_address_id = azurerm_public_ip.gwyip[each.key].id
      subnet_id            = azurerm_subnet.subnets[var.gatewaysubnet_subnet_name].id
    }
    tags                   = merge( var.tags, local.resource-tags["azurerm_virtual_network_gateway"] )
}

resource "azurerm_virtual_network_gateway_connection" "PrimaryGatewayConnection" {
  for_each = var.express_route_circuit
    name                       = "exprtconn-${var.name-vars["account"]}-${var.name-vars["name"]}-${each.key}"
    location                   = var.region
    resource_group_name        = azurerm_resource_group.rg-vnet.name
    type                       = var.azurerm_virtual_network_gateway_type
    virtual_network_gateway_id = azurerm_virtual_network_gateway.gwy[each.key].id
    express_route_circuit_id   = azurerm_express_route_circuit.ExpressRouteCircuit[each.key].id
}
