resource "azurerm_resource_group" "rg" {
  name     = "devops00-rg-${var.env}"
  location = var.location
}