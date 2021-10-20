locals {
  emptymaps = [{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]
  resource_list = ["azurerm_virtual_network", "azurerm_resource_group", "azurerm_subnet", "azurerm_route_table", "azurerm_network_security_group", "azurerm_network_watcher_flow_log", "azurerm_network_watcher", "azurerm_public_ip", "azurerm_virtual_network_gateway", "azurerm_express_route_circuit"]
  empty-resource-tags = zipmap(local.resource_list, slice(local.emptymaps, 0 ,length(local.resource_list)))
  resource-tags = merge(local.empty-resource-tags, var.resource-tags)

  subnets = {
    for name in keys(var.subnets) : name => {
      address_prefix   = azurerm_subnet.subnets[name].address_prefix
      address_prefixes = azurerm_subnet.subnets[name].address_prefixes
      id               = azurerm_subnet.subnets[name].id
      name             = azurerm_subnet.subnets[name].name
    }
  }

  route_table_ids = {
    for k,s in var.subnets : k => azurerm_route_table.router[k].id
  }
  
  network_security_group_names = {
    for k, v in var.subnets: k => azurerm_network_security_group.security_groups[k].name
    if k != "GatewaySubnet"
  }

  subnet_specific_routes = {
    for ks in keys(local.subnets) :  ks => flatten([
      for kd, vd in local.subnets : ( ks!=kd ? vd["address_prefixes"] : [] )
    ])
  }

  subnet_specific_routes_add = flatten([
    for k, v in local.subnet_specific_routes : [
      for ii, c in v : {
        name   = replace("${k}-${c}", "/", "-")
        key    = k
        cidr   = c
        next_hop_in_ip_address = var.set_subnet_specific_next_hop_in_ip_address[k]
      }
    if k != "pub" && length(keys(var.set_subnet_specific_next_hop_in_ip_address)) == length(keys(var.subnets))-1
    ] 
  ])
  
}
