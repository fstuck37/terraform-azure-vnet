resource "azurerm_network_watcher_flow_log" "flow-log" {
  for_each = { for k, v in var.subnets: k => v if k != var.gatewaysubnet_subnet_name && var.log-storage-account != "" && var.network_watcher_name != "" && var.network_watcher_resource_group_name !="" }
    network_watcher_name      = var.network_watcher_name
    resource_group_name       = var.network_watcher_resource_group_name
    network_security_group_id = azurerm_network_security_group.security_groups[each.key].id
    storage_account_id        = var.log-storage-account
    enabled                   = true
    tags                      = merge( var.tags, local.resource-tags["azurerm_network_watcher_flow_log"] )
    retention_policy {
      enabled = true
      days    = var.log-retention
    }
}
