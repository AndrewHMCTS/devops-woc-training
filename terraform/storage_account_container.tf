resource "azurerm_storage_account" "sa" {
  name                           = "devopswocstorage"
  resource_group_name            = azurerm_resource_group.rg.name
  location                       = azurerm_resource_group.rg.location
  account_tier                   = "Standard"
  account_replication_type       = "LRS"
  enable_heierarchical_namespace = true
}

resource "azurerm_storage_container" "container" {
  name                 = "devopswoc"
  storage_account_name = azurerm_storage_account.sa.name
}

data "azurerm_storage_account" "sa" {
  name                = azurerm_storage_account.sa.name
  resource_group_name = azurerm_resource_group.rg.name
}