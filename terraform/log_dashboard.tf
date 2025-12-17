#Update once I make a dashboard in UI and export proerties
# resource "azurerm_portal_dashboard" "appservice" {
#   name                = "dash-devopswoc-${var.env}"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location

#   tags = {
#     Environment = var.env
#   }
# }