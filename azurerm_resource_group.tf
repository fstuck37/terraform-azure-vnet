resource "azurerm_resource_group" "rg-vnet" {
  name     = var.vnet-name == "" ? "rg-${var.name-vars["account"]}-${var.region}-${var.name-vars["name"]}" : "rg-${var.vnet-name}"
  location = var.region
  tags     = merge( var.tags, local.resource-tags["azurerm_resource_group"] )
}