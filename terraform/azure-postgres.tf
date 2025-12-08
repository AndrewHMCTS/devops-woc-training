resource "random_password" "pg_password" {
  length           = 16
  special          = true
  override_characters = "!@#$%&*()-_=+"
}

resource "azurerm_postgresql_flexible_server" "pg" {
  name                = "devopswoc-db-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  version             = "15"
  administrator_login          = "pgadmin"
  administrator_password       = random_password.pg_password.result
  sku_name            = "Standard_B1ms"
  storage_mb          = 32768
  backup_retention_days = 7
  high_availability_mode = "Disabled"
  delegated_subnet_id  = null
  public_network_access_enabled = true
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name                = "filevault_db"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_flexible_server.pg.name
  charset             = "UTF8"
  collation           = "English_United Kingdom.1252"
}