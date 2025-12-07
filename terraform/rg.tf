resource "azurerm_resource_group" "rg" {
  name     = "rg-filevault-${var.env}"
  location = var.location
}