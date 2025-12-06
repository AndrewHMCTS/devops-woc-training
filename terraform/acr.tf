resource "azurerm_container_registry" "acr" {
  name                = "filevaultacr-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}