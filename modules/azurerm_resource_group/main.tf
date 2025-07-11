resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_resource_group" "resource_group2" {
  name     = var.resource_group_name2
  location = var.resource_group_location
}