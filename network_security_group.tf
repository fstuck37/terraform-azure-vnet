resource "azurerm_network_security_group" "security_groups" {
  for_each = { for k, v in var.subnets: k => v if k != var.gatewaysubnet_subnet_name && !contains(keys(var.set_subnet_specific_delegation), k)}
    name                = "nsg-${var.name-vars["account"]}-${var.name-vars["name"]}-${each.key}"
    location            = var.region
    resource_group_name = azurerm_resource_group.rg-vnet.name
    tags                = merge( var.tags, local.resource-tags["azurerm_network_security_group"] )
}

resource "azurerm_network_security_rule" "lb-in-4095" {
  for_each = { for k, v in var.subnets: k => v if k != var.gatewaysubnet_subnet_name && k != var.public_subnet_name && var.default_deny_all && !contains(keys(var.set_subnet_specific_delegation), k)}
    name                          = "AllowAzureLoadBalancerInBound-TCP"
    priority                      = 4095
    direction                     = "Inbound"
    access                        = "Allow"
    protocol                      = "Tcp"
    source_address_prefix         = "AzureLoadBalancer"
    source_port_range             = "*"
    destination_address_prefixes  = azurerm_subnet.subnets[each.key].address_prefixes
    destination_port_range        = "*"
    resource_group_name           = azurerm_resource_group.rg-vnet.name
    network_security_group_name   = azurerm_network_security_group.security_groups[each.key].name
}

resource "azurerm_network_security_rule" "DenyAllInBound" {
  for_each = { for k, v in var.subnets: k => v if k != var.gatewaysubnet_subnet_name && k != var.public_subnet_name && var.default_deny_all && !contains(keys(var.set_subnet_specific_delegation), k)}
    name                        = "Block All Ingress"
    priority                    = 4096
    direction                   = "Inbound"
    access                      = "Deny"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.rg-vnet.name
    network_security_group_name = azurerm_network_security_group.security_groups[each.key].name
}

resource "azurerm_subnet_network_security_group_association" "sg_association" {
  for_each = { for k, v in var.subnets: k => v if k != var.gatewaysubnet_subnet_name && !contains(keys(var.set_subnet_specific_delegation), k)}
    subnet_id                 = azurerm_subnet.subnets[each.key].id
    network_security_group_id = azurerm_network_security_group.security_groups[each.key].id
}





