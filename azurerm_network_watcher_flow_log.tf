resource "azurerm_network_watcher_flow_log" "flow-log" {
  for_each = { for k, v in var.subnets: k => v if k != var.gatewaysubnet_subnet_name && var.log-storage-account != "" && var.network_watcher_name != "" && var.network_watcher_resource_group_name !="" && !contains(keys(var.set_subnet_specific_delegation), k) }
    name                      = var.vnet-name == "" ? "Microsoft.Networkrg-${var.name-vars["account"]}-${var.region}-${var.name-vars["name"]}nsg-${var.name-vars["account"]}-${var.name-vars["name"]}-${each.key}" : "Microsoft.Networkrg-${var.vnet-name}nsg-${var.name-vars["account"]}-${var.name-vars["name"]}-${each.key}"
    network_watcher_name      = var.network_watcher_name
    resource_group_name       = var.network_watcher_resource_group_name
    network_security_group_id = azurerm_network_security_group.security_groups[each.key].id
    storage_account_id        = var.log-storage-account
    enabled                   = true
    location                  = var.region
    tags                      = merge( var.tags, local.resource-tags["azurerm_network_watcher_flow_log"] )
    retention_policy {
      enabled = true
      days    = var.log-retention
    }
}
